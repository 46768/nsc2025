"""
Packet reverse proxy server
"""
import sys
import os

import json
import packet

import vfs
import code_execution
import ast_sec

import logging

import asyncio
from websockets.asyncio.server import serve

logger = logging.getLogger(__name__)


def cancel_all_tasks():
    pending = asyncio.all_tasks()
    for task in pending:
        if not task.done():
            logger.info("Canceling task '%s'", task.get_name())
            task.cancel()
    logger.info("Canceled all tasks")


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

    async def reverse_proxy(websocket):
        # websocket.send alias for sending packets
        async def send_pkt(x): await websocket.send(json.dumps(x))

        # Route packet to the target handler by type
        async def route_packet(pkt_json):
            pkt_hash = str(pkt_json["hash"])
            pkt_type = str(pkt_json["type"])
            match pkt_type:
                case "ces:exec":  # Request code execution
                    ret_pkt = code_execution.handle_vfs_execution_pkt(
                            pkt_json, interpreter, vfs_mgr, ast_checker)
                    await send_pkt(ret_pkt)
                case "rpx:end":  # Request to close the server
                    logger.info("Received stop server packet, stopping server")
                    cancel_all_tasks()
                case _:  # Send type error for unhandled pkt type
                    packet.log_packet_issue("invalid type", pkt_json)
                    await send_pkt(
                            packet.pkt_err("type", pkt_hash+":"+pkt_type))

        # Main loop
        async for pkt_str in websocket:
            pkt_json = json.loads(pkt_str)
            pkt_hash = str(pkt_json["hash"])

            # Packet verifying to ensure no data corruption
            computed_hash = packet.hash_packet(pkt_json)
            if pkt_hash != computed_hash:
                packet.log_packet_issue(
                        "mismatched hash", pkt_json, computed_hash)
                await send_pkt(packet.pkt_err("hash", pkt_hash))
                continue

            # Send received confirmation
            await send_pkt(packet.pkt_confirm(pkt_json))

            await route_packet(pkt_json)

    return reverse_proxy


async def server(port, interpreter, data_path, ast_blacklist):
    logger.info("""
Starting server, server configurations:
    port: %s
    python executioner: %s
    server data path: %s""",
                port,
                interpreter,
                data_path)

    async with serve(
            build_reverse_proxy(interpreter,
                                data_path,
                                ast_blacklist), "localhost", port
            ) as server:
        try:
            logger.info("Started server")
            await server.serve_forever()
        except asyncio.exceptions.CancelledError:
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

    asyncio.run(server(port,
                       python_interpreter_path,
                       data_path,
                       ast_blacklist_path))
