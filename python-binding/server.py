import sys

import json
import packet

import vfs
import code_execution

import asyncio
from websockets.asyncio.server import serve


def build_reverse_proxy(interpreter, data_path):
    vfs_mgr = vfs.VFSMgr(data_path)

    async def reverse_proxy(websocket):
        async def send_pkt(x): await websocket.send(json.dumps(x))
        async for pkt in websocket:
            pkt_json = json.loads(pkt)
            pkt_hash = str(pkt_json["hash"])

            # Packet verifying to ensure no data corruption
            if pkt_hash != packet.hash_packet(pkt_json):
                await send_pkt(packet.pkt_err("hash", pkt_hash))
                continue

            # Send received confirmation
            await send_pkt(packet.pkt_confirm(pkt_json))

            packet_type = str(pkt_json["type"])
            match packet_type:
                case "ces:exec":
                    ret_pkt = code_execution.handle_vfs_execution_pkt(
                            pkt_json, interpreter, vfs_mgr
                    )
                    await send_pkt(ret_pkt)
                case _:
                    # Send type error for unhandled pkt type
                    await send_pkt(packet.pkt_err("type", pkt_hash))

    return reverse_proxy


async def server(port, interpreter, data_path):
    async with serve(
            build_reverse_proxy(interpreter, data_path), "localhost", port
            ) as server:
        await server.serve_forever()


if __name__ == "__main__":
    if len(sys.argv) != 4:
        fname = sys.argv[0]
        print(
            f"{fname}: Invalid usage: python3 {fname} [port] [python intepreter] [data path]"
        )
        exit(1)
    port = sys.argv[1]
    python_interpreter = sys.argv[2]
    data_path = sys.argv[3]

    asyncio.run(server(port, python_interpreter, data_path))
