import json

import asyncio
from websockets.asyncio.client import connect

import hashlib
import time


def hash_packet(packet) -> str:
    pkt_time = packet["time"]
    pkt_type = packet["type"]
    pkt_content = packet["content"]

    hash_str = hashlib.sha256(bytes(
            str(pkt_time) +
            str(pkt_type) +
            str(pkt_content),
            "ascii")).hexdigest()
    return hash_str


def build_packet(pkt_type, pkt_content):
    packet = {
        "time": str(time.time()),
        "type": str(pkt_type),
        "content": str(pkt_content),
    }
    hash_str = hash_packet(packet)
    packet["hash"] = hash_str
    return packet


def pkt_err(err_type, pkt_content):
    return build_packet("err:"+err_type, pkt_content)


def pkt_confirm(pkt):
    return build_packet("pkt:recv", str(pkt["hash"]))


vfs_string = json.dumps({
    "name": "testvfs",
    "/": {
        "type": 0,
        "content": {
            "/main.py": True,
        },
    },
    "/main.py": {
        "type": 1,
        "content": "import sys;print('hello world!');print('hello error!',file=sys.stderr)"
    },
})
entry_point = "/main.py"


async def send_pkt_close():
    async with connect("ws://localhost:56440") as websocket:
        pkt = build_packet("rpx:end", "")
        await websocket.send(json.dumps(pkt))
        message = await websocket.recv()
        print(message)

if __name__ == "__main__":
    asyncio.run(send_pkt_close())
