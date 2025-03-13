import sys
from ces.networking import packet
from http import client


vfs_string = {
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
}
vfs_string_forbidden = {
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
}
entry_point = "/main.py"


def test_ping_pong():
    pkt = packet.build_packet("/net", "ping:pong", 000, {
        "ping": "pong",
        "pang": "pung"})
    headers = pkt["headers"]
    content = pkt["content"]
    conn = client.HTTPConnection(f"localhost:{port}")
    conn.request("POST", pkt["url"], content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


def test_exec():
    pkt = packet.build_packet("/execution", "request", 000, {
        "vfs": vfs_string,
        "entryPoint": entry_point})
    headers = pkt["headers"]
    content = pkt["content"]
    conn = client.HTTPConnection(f"localhost:{port}")
    conn.request("POST", pkt["url"], content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


def test_exec_forbid():
    pkt = packet.build_packet("/execution", "request", 000, {
        "vfs": vfs_string_forbidden,
        "entryPoint": entry_point})
    headers = pkt["headers"]
    content = pkt["content"]
    conn = client.HTTPConnection(f"localhost:{port}")
    conn.request("POST", pkt["url"], content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


def test_bad_url():
    pkt = packet.build_packet("/nonexist", "request", 000, {
        "vfs": vfs_string_forbidden,
        "entryPoint": entry_point})
    headers = pkt["headers"]
    content = pkt["content"]
    conn = client.HTTPConnection(f"localhost:{port}")
    conn.request("POST", pkt["url"], content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


def test_bad_method():
    pkt = packet.build_packet("/execution", "nonexist", 000, {
        "vfs": vfs_string_forbidden,
        "entryPoint": entry_point})
    headers = pkt["headers"]
    content = pkt["content"]
    conn = client.HTTPConnection(f"localhost:{port}")
    conn.request("POST", pkt["url"], content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


def test_bad_hash():
    pkt = packet.build_packet("/execution", "request", 000, {
        "vfs": vfs_string_forbidden,
        "entryPoint": entry_point})
    pkt["headers"]["p-time"] = str(float(pkt["headers"]["p-time"])+0.00001)
    headers = pkt["headers"]
    content = pkt["content"]
    conn = client.HTTPConnection(f"localhost:{port}")
    conn.request("POST", pkt["url"], content, headers)
    respose = conn.getresponse()
    print(respose.status, respose.reason)
    print(respose.read())
    conn.close()


if __name__ == "__main__":
    if len(sys.argv) != 2:
        fname = sys.argv[0]
        print(f"{fname}: Invalid usage: python3 {fname} port")
        exit(1)
    port = sys.argv[1]

    test_ping_pong()
    test_exec()
    test_exec_forbid()
    test_bad_url()
    test_bad_method()
    test_bad_hash()
