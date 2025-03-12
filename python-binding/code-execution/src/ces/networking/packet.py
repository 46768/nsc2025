"""
Packet utilites module
"""

import hashlib
import json
import time
import logging

logger = logging.getLogger(__name__)


def hash_packet(packet) -> str:
    hash_str = hashlib.sha256(bytes(
            str(packet["headers"]["p-time"])
            + str(packet["headers"]["p-type"])
            + str(packet["content"]),
            "ascii")).hexdigest()
    return hash_str


def build_packet(pkt_url, pkt_type, pkt_code, pkt_content):
    packet = {
        "url": str(pkt_url),
        "code": pkt_code,
        "headers": {
            "p-time": str(time.time()),
            "p-type": str(pkt_type),
        },
        "content": json.dumps(pkt_content),
    }
    hash_str = hash_packet(packet)
    packet["headers"]["p-hash"] = str(hash_str)
    packet["headers"]["content-length"] = len(packet["content"])
    return packet


def decode_packet(url, headers, content_str):
    packet = {
        "url": str(url),
        "code": 000,
        "headers": {
            "p-time": headers.get("p-time", "pkt:404"),
            "p-type": headers.get("p-type", "pkt:404"),
            "p-hash": headers.get("p-hash", "pkt:404"),
        },
        "content": content_str,
    }
    return packet


def log_packet_issue(issue_str, pkt_json, computed_hash=None):
    logger.warning("""
Found %s, packet data:
    packet url: %s
    packet time: %s
    packet type: %s
    packet content: %s
    packet hash: %s
    computed hash: %s""",
                   issue_str,
                   pkt_json["headers"]["p-hash"],
                   computed_hash or "N/A",
                   pkt_json["url"],
                   pkt_json["headers"]["p-time"],
                   pkt_json["headers"]["p-type"],
                   pkt_json["content"])
