"""
Code execution server networking interface
"""
import packet
import logging
from http import server
import threading

logger = logging.getLogger(__name__)


class Handler(server.BaseHTTPRequestHandler):
    def configure_reverse_proxy(self, rproxy):
        self.reverse_proxy = rproxy

    def send_pkt(self, pkt):
        self.send_response(int(pkt["code"]))
        self.send_header("content-type", "application/json")
        for k, v in pkt["headers"].items():
            self.send_header(str(k), str(v))
        self.end_headers()
        self.wfile.write(pkt["content"].encode('utf-8'))

    def verify_packet(self, pkt_json):
        pkt_hash = pkt_json["headers"]["p-hash"]
        computed_hash = packet.hash_packet(pkt_json)
        if pkt_hash != computed_hash:
            packet.log_packet_issue(
                    "Mismatched Hash", pkt_json, computed_hash)
            return False
        return True

    # Main loop
    def do_POST(self):
        content_length = int(self.headers.get("content-length", 0))
        post_data = self.rfile.read(content_length).decode('utf-8')
        pkt_json = packet.decode_packet(self.headers, post_data)

        # Packet verifying to ensure no data corruption
        if not self.verify_packet(pkt_json):
            self.send_pkt(packet.build_packet(
                    "/", "err:hash", 400, {"msg": "Mismatched Hash"}))
        else:
            response_pkt = self.reverse_proxy.route_packet(pkt_json)
            self.send_pkt(response_pkt)
            if response_pkt["url"] == "/net/shutdown":
                logger.info("Received shutdown packet, shutting down server")
                threading.Thread(target=self.server.shutdown,
                                 daemon=True).start()


def start_server(port, rproxy):
    logger.info("Starting server")
    server_address = ("localhost", int(port))
    servr = server.HTTPServer(server_address, Handler)
    servr.RequestHandlerClass.configure_reverse_proxy(rproxy)

    logger.info("Started server")
    try:
        servr.serve_forever()
    finally:
        servr.server_close()
        logger.info("Stopped server")
