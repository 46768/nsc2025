"""
Packet reverse proxy server
"""
import sys
import os
import atexit

import packet

import vfs
import code_execution
import ast_sec

import logging

from http import server
import threading

logger = logging.getLogger(__name__)


def exit_handler():
    logger.info("Server process ending")


def build_reverse_proxy(interpreter, data_path, ast_blacklist):
    vfs_cache_path = os.path.join(data_path, "vfs_cache")
    if not os.path.exists(vfs_cache_path):
        os.mkdir(vfs_cache_path)
    vfs_mgr = vfs.VFSMgr(vfs_cache_path)
    ast_checker = ast_sec.ASTChecker(ast_blacklist)

    class reverse_proxy(server.BaseHTTPRequestHandler):
        protocol_version = "HTTP/1.0"

        # websocket.send alias for sending packets
        def send_pkt(self, pkt, code=200):
            self.send_response(code)
            self.send_header("content-type", "application/json")
            for k, v in pkt["headers"].items():
                self.send_header(str(k), str(v))
            self.end_headers()
            self.wfile.write(pkt["content"].encode('utf-8'))

        # Route packet to the target handler by type
        def route_packet(self, pkt_json):
            pkt_type = str(pkt_json["headers"]["p-type"])
            match pkt_type:
                # Request code execution
                case "ces:exec":
                    ret_pkt = code_execution.handle_vfs_execution_pkt(
                            pkt_json, interpreter, vfs_mgr, ast_checker)
                    self.send_pkt(ret_pkt)

                # Server response test
                case "rpx:ping":
                    self.send_pkt(packet.build_packet("rpx:pong",
                                                      {"msg": "pung"}))

                # Request to close the server
                case "rpx:end":
                    logger.info("Received stop server packet, stopping server")
                    self.send_pkt(packet.build_packet("rpx:end",
                                                      {"msg": "Goodbye"}))
                    threading.Thread(target=self.server.shutdown,
                                     daemon=True).start()

                # Send type error for unhandled pkt type
                case _:
                    packet.log_packet_issue("invalid type", pkt_json)
                    self.send_pkt(
                            packet.build_packet("err:type",
                                                {"invalid-type": pkt_type}),
                            404)

        def verify_packet(self, pkt_json):
            pkt_hash = pkt_json["headers"]["p-hash"]
            computed_hash = packet.hash_packet(pkt_json)
            if pkt_hash != computed_hash:
                packet.log_packet_issue(
                        "mismatched hash", pkt_json, computed_hash)
                return False
            return True

        # Main loop
        def do_POST(self):
            content_length = int(self.headers.get("content-length", 0))
            post_data = self.rfile.read(content_length).decode('utf-8')
            pkt_json = packet.decode_packet(self.headers, post_data)

            # Packet verifying to ensure no data corruption
            if not self.verify_packet(pkt_json):
                self.send_pkt(packet.build_packet("err:hash",
                                                  {"msg": "Hash Error"}), 400)
                return

            self.route_packet(pkt_json)

    return reverse_proxy


def start_server(port, interpreter, data_path, ast_blacklist):
    logger.info("""
Starting server, server configurations:
    port: %s
    python executioner: %s
    server data path: %s""",
                port,
                interpreter,
                data_path)

    logger.info("Started server")
    server_address = ("localhost", int(port))
    servr = server.HTTPServer(
            server_address,
            build_reverse_proxy(interpreter, data_path, ast_blacklist))

    try:
        servr.serve_forever()
    finally:
        servr.server_close()
        logger.info("Stopping server")


if __name__ == "__main__":
    if len(sys.argv) != 5:
        fname = sys.argv[0]
        print(
            f"{fname}: Invalid usage: "
            + f"python3 {fname} port python-intepreter-path data-path "
            + "ast-blacklist-path")
        exit(1)
    port = sys.argv[1]
    python_interpreter_path = sys.argv[2]
    data_path = sys.argv[3]
    ast_blacklist_path = sys.argv[4]
    logging.basicConfig(
            filename=os.path.join(data_path, "server.log"),
            filemode='w',
            format="[%(levelname)s]"
            + "{%(asctime)s}"
            + "(%(name)s:%(filename)s:%(funcName)s:%(lineno)s): "
            + "%(message)s",
            encoding="ascii",
            level=logging.INFO)
    atexit.register(exit_handler)

    start_server(port,
                 python_interpreter_path,
                 data_path,
                 ast_blacklist_path)
