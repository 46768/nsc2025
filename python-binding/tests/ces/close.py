import json

from http import client

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


def send_close():
    pkt = build_packet("rpx:end", "THY END IS NOW!!!")
    content = json.dumps(pkt)
    headers = {"Content-type": "application/json",
               "Accept": "application/json"}
    conn = client.HTTPConnection("localhost:56440")
    conn.request("POST", "", content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


if __name__ == "__main__":
    send_close()
