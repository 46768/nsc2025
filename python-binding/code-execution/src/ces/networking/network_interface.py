"""Network interface for handling network packet

The network interface for routing network
packets to a handler based on url, and
packet method
"""

from ces.networking import packet
import logging
from http import server
import threading

logger = logging.getLogger(__name__)


class ReverseProxyHTTPRequestHandler(server.BaseHTTPRequestHandler):
    """HTTP request handler with a reverse proxy for packet routing

    Attributes:
        reverse_proxy (ReverseProxy): The reverse proxy used by the server
    """

    def setup(self):
        """Setup BaseHTTPRequestHandler, and assigns the reverse proxy

        Setup the handler using BaseHTTPRequestHandler, then assigns
        the reverse proxy in the server to the handler for easy access
        """

        server.BaseHTTPRequestHandler.setup(self)
        self.reverse_proxy = self.server.reverse_proxy

    def send_pkt(self, pkt):
        """Send a packet back to the client

        Args:
            pkt (packet): The packet to send
        """

        self.send_response(int(pkt["code"]))
        self.send_header("content-type", "application/json")
        for k, v in pkt["headers"].items():
            self.send_header(str(k), str(v))
        self.end_headers()
        self.wfile.write(pkt["content"].encode('utf-8'))

    def verify_packet(self, pkt_json):
        """Verify a packet to its hash

        Args:
            pkt_json (Packet): The packet to verify

        Returns:
            bool: True if packet hash matches the
            computed hash, False otherwise
        """

        pkt_hash = pkt_json["headers"]["p-hash"]
        computed_hash = packet.hash_packet(pkt_json)
        if pkt_hash != computed_hash:
            packet.log_packet_issue(
                    "Mismatched Hash", pkt_json, computed_hash)
            return False
        return True

    def do_POST(self):
        # Decode raw data into packet
        content_length = int(self.headers.get("content-length", 0))
        post_data = self.rfile.read(content_length).decode('utf-8')
        pkt_json = packet.decode_packet(self.path, self.headers, post_data)

        # Packet verifying to ensure no data corruption
        if not self.verify_packet(pkt_json):
            self.send_pkt(packet.build_packet(
                    "/net", "err:hash", 400, {"msg": "Mismatched Hash"}))

        # Route the packet using the reverse proxy assigned
        else:
            try:
                response_pkt = self.reverse_proxy.route_packet(pkt_json)
                self.send_pkt(response_pkt)

                # Handles shutdown packet
                if (response_pkt["url"] == "/net"
                        and response_pkt["headers"]["p-type"] == "shutdown"):
                    logger.info(
                            "Received shutdown packet, shutting down server")
                    threading.Thread(target=self.server.shutdown,
                                     daemon=True).start()

            # Handle any handler exceptions with 500 Internal Server Error
            except Exception:
                self.send_pkt(packet.build_packet(
                        pkt_json["url"],
                        pkt_json["headers"]["p-type"]+":err:internal", 500,
                        {"msg": "Server Error"}))


def start_server(port, rproxy):
    """Start a reverse proxy server with the given
    reverse proxy handler

    Args:
        port (int): Port number of the server
        rproxy (ReverseProxy): The reverse proxy handler
    """

    logger.info("Starting server")
    server_address = ("localhost", int(port))
    servr = server.HTTPServer(server_address, ReverseProxyHTTPRequestHandler)
    servr.reverse_proxy = rproxy

    logger.info("Started server")
    try:
        servr.serve_forever()
    finally:
        servr.server_close()
        logger.info("Stopped server")
