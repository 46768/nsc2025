import json

from http import client
import urllib

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


def test_ok():
    pkt = build_packet("ces:exec", json.dumps({
        "vfs": vfs_string, "entryPoint": entry_point}))
    content = json.dumps(pkt)
    headers = {"Content-type": "application/json",
               "Accept": "application/json"}
    conn = client.HTTPConnection("localhost:56440")
    conn.request("POST", "", content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


def test_hash_err():
    pkt = build_packet("ces:exec", json.dumps({
        "vfs": vfs_string, "entryPoint": entry_point}))
    pkt["time"] = str(float(pkt["time"])+0.00001)
    content = json.dumps(pkt)
    headers = {"Content-type": "application/json",
               "Accept": "application/json"}
    conn = client.HTTPConnection("localhost:56440")
    conn.request("POST", "", content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


def test_type_err():
    pkt = build_packet("ces:nonexist", json.dumps({
        "vfs": vfs_string, "entryPoint": entry_point}))
    content = json.dumps(pkt)
    headers = {"Content-type": "application/json",
               "Accept": "application/json"}
    conn = client.HTTPConnection("localhost:56440")
    conn.request("POST", "", content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


def test_forbid():
    pkt = build_packet("ces:exec", json.dumps({
        "vfs": vfs_string_forbidden, "entryPoint": entry_point}))
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
    test_ok()
    test_hash_err()
    test_type_err()
    test_forbid()
