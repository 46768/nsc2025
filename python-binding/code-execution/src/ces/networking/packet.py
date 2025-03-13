"""Packet utilities

A utility module for building, hashing, and logging
packets

Notes:
    dict will be replaced with the Packet class in
    the future
"""

import hashlib
import json
import time
import logging

logger = logging.getLogger(__name__)


def hash_packet(packet) -> str:
    """Hash a packet with SHA256

    Hash a packet using its time, type, and content
    concatenated with SHA256

    Args:
        packet (Packet): The packet to get the hash of

    Returns:
        str: The hex string of the hash of the packet
    """

    hash_str = hashlib.sha256(bytes(
            str(packet["headers"]["p-time"])
            + str(packet["headers"]["p-type"])
            + str(packet["content"]),
            "ascii")).hexdigest()
    return hash_str


def build_packet(pkt_url, pkt_type, pkt_code, pkt_content):
    """Build a packet based on given arguments

    Args:
        pkt_url (str): URL destination of the packet
        pkt_type (str): Type of the packet, used as method of the URL
        pkt_code (int): HTTP code of the packet
        pkt_content (dict): Packet content, will be stringified into JSON

    Returns:
        Packet: A dictionary containing packet data
    """

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
    """Build a packet from HTTP request data

    Args:
        url (str): URL of the request
        headers (MessageClass): Headers of the request
        content_str (str): Content of the request. read from rfile

    Returns:
        Packet: The packet from the request
    """

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
    """Logs an issue with the given packet for debugging

    Logs the url, time, type, content, packet hash,
    and computed hash of a packet for debugging.
    If computed hash isn't provided then `N/A`
    will be in place of the hash

    Args:
        issue_str (str): Issue with the packet
        pkt_json (Packet): Packet with the issue
        computed_hash (str): Computed hash of the packet
    """

    logger.warning("""
Found %s, packet data:
    packet url: %s
    packet time: %s
    packet type: %s
    packet content: %s
    packet hash: %s
    computed hash: %s""",
                   issue_str,
                   pkt_json["url"],
                   pkt_json["headers"]["p-time"],
                   pkt_json["headers"]["p-type"],
                   pkt_json["content"],
                   pkt_json["headers"]["p-hash"],
                   computed_hash or "N/A")
