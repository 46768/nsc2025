"""
Packet reverse proxy server
"""
import sys
import os
import atexit

import json
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
    """
    Builds a reverse proxy with code execution support

    Args:
        interpreter (str): The path to a python3 interpreter
        data_path (str): The path to where logs and vfs cache will be stored
        ast_blacklist (str): The path to the ast blacklist as .yml file

    Returns:
        (func): A function for handling websocket connection,
        to be used with websockets.asyncio.server.serve
    """

    vfs_cache_path = os.path.join(data_path, "vfs_cache")
    if not os.path.exists(vfs_cache_path):
        os.mkdir(vfs_cache_path)
    vfs_mgr = vfs.VFSMgr(vfs_cache_path)
    ast_checker = ast_sec.ASTChecker(ast_blacklist)

    class reverse_proxy(server.BaseHTTPRequestHandler):
        # websocket.send alias for sending packets
        def send_pkt(self, x, code=200):
            self.send_response(code)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(x).encode('utf-8'))
            self.wfile.flush()

        # Route packet to the target handler by type
        def route_packet(self, pkt_json):
            pkt_hash = str(pkt_json["hash"])
            pkt_type = str(pkt_json["type"])
            match pkt_type:
                case "ces:exec":  # Request code execution
                    ret_pkt = code_execution.handle_vfs_execution_pkt(
                            pkt_json, interpreter, vfs_mgr, ast_checker)
                    self.send_pkt(ret_pkt)
                case "rpx:ping":
                    self.send_pkt(packet.build_packet("rpx:pong", pkt_hash))
                case "rpx:end":  # Request to close the server
                    logger.info("Received stop server packet, stopping server")
                    self.send_pkt(packet.build_packet("rpx:end", "goodbye"))
                    threading.Thread(target=self.server.shutdown,
                                     daemon=True).start()
                    # self.server.shutdown()
                case _:  # Send type error for unhandled pkt type
                    packet.log_packet_issue("invalid type", pkt_json)
                    self.send_pkt(
                            packet.pkt_err("type", pkt_hash+":"+pkt_type), 404)

        # Main loop
        def do_POST(self):
            content_length = int(self.headers.get("Content-Length", 0))
            post_data = self.rfile.read(content_length).decode('utf-8')
            pkt_json = json.loads(post_data)
            pkt_hash = str(pkt_json["hash"])

            # Packet verifying to ensure no data corruption
            computed_hash = packet.hash_packet(pkt_json)
            if pkt_hash != computed_hash:
                packet.log_packet_issue(
                        "mismatched hash", pkt_json, computed_hash)
                self.send_pkt(packet.pkt_err("hash", pkt_hash))
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
    servr = server.HTTPServer(server_address,
                              build_reverse_proxy(interpreter,
                                                  data_path,
                                                  ast_blacklist))
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
