import json

from http import client

import hashlib
import time


def hash_packet(packet) -> str:
    hash_str = hashlib.sha256(bytes(
            str(packet["headers"]["p-time"])
            + str(packet["headers"]["p-type"])
            + str(packet["content"]),
            "ascii")).hexdigest()
    return hash_str


def build_packet(pkt_type, pkt_content):
    packet = {
        "headers": {
            "p-time": str(time.time()),
            "p-type": str(pkt_type),
        },
        "content": json.dumps(pkt_content),
    }
    hash_str = hash_packet(packet)
    packet["headers"]["p-hash"] = str(hash_str)
    return packet


def send_close():
    pkt = build_packet("rpx:end", {
        "msg": "THY END IS NOW!!!"})
    headers = pkt["headers"]
    content = pkt["content"]
    conn = client.HTTPConnection("localhost:56440")
    conn.request("POST", "", content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


if __name__ == "__main__":
    send_close()
