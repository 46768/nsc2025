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


def build_packet_static():
    packet = {
        "headers": {
            "p-time": '0',
            "p-type": 'rpx:ping',
        },
        "content": json.dumps({"msg": "pang"}),
    }
    hash_str = hash_packet(packet)
    packet["headers"]["p-hash"] = str(hash_str)
    return packet


vfs_string = json.dumps({
    "name": "testvfs",
    "/": {
        "type": 1,
        "content": {
            "/main.py": True,
        },
    },
    "/main.py": {
        "type": 0,
        "content": "import sys;print('hello world!');print('hello error!',file=sys.stderr)"
    },
})
vfs_string_forbidden = json.dumps({
    "name": "testvfs",
    "/": {
        "type": 1,
        "content": {
            "/main.py": True,
            "/forbidden.py": True,
        },
    },
    "/main.py": {
        "type": 0,
        "content": "import sys;print('hello world!');print('hello error!',file=sys.stderr)"
    },
    "/forbidden.py": {
        "type": 0,
        "content": "import os;print(os.environ);eval('1+1');exec('x=1');__import__('subprocess');x=__import__;x('os');eval=1"
    },
})
entry_point = "/main.py"


def test_ok_hash():
    pkt = build_packet_static()
    headers = pkt["headers"]
    content = pkt["content"]
    conn = client.HTTPConnection("localhost:56440")
    conn.request("POST", "", content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


def test_ok():
    pkt = build_packet("ces:exec", {
        "vfs": vfs_string, "entryPoint": entry_point})
    headers = pkt["headers"]
    content = pkt["content"]
    conn = client.HTTPConnection("localhost:56440")
    conn.request("POST", "", content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


def test_hash_err():
    pkt = build_packet("ces:exec", {
        "vfs": vfs_string, "entryPoint": entry_point})
    pkt["headers"]["p-time"] = str(float(pkt["headers"]["p-time"])+0.00001)
    headers = pkt["headers"]
    content = pkt["content"]
    conn = client.HTTPConnection("localhost:56440")
    conn.request("POST", "", content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


def test_type_err():
    pkt = build_packet("ces:nonexist", {
        "vfs": vfs_string, "entryPoint": entry_point})
    headers = pkt["headers"]
    content = pkt["content"]
    conn = client.HTTPConnection("localhost:56440")
    conn.request("POST", "", content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


def test_forbid():
    pkt = build_packet("ces:exec", {
        "vfs": vfs_string_forbidden, "entryPoint": entry_point})
    headers = pkt["headers"]
    content = pkt["content"]
    conn = client.HTTPConnection("localhost:56440")
    conn.request("POST", "", content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


if __name__ == "__main__":
    test_ok()
    test_hash_err()
    test_type_err()
    test_forbid()
    test_ok_hash()
