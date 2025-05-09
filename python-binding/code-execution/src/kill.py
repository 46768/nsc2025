import sys
from ces.networking import packet
from http import client


if __name__ == "__main__":
    if len(sys.argv) != 2:
        fname = sys.argv[0]
        print(f"{fname}: Invalid usage: python3 {fname} port")
        exit(1)
    port = sys.argv[1]
    pkt = packet.build_packet("/net", "shutdown", 000, {
        "msg": "THY END IS NOW!!!"})
    headers = pkt["headers"]
    content = pkt["content"]
    conn = client.HTTPConnection(f"localhost:{port}")
    conn.request("POST", pkt["url"], content, headers)
    conn.getresponse()
    conn.close()
