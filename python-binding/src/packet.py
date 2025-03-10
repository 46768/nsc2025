"""
Packet utilites module
"""
import hashlib
import time
import logging

logger = logging.getLogger(__name__)


def hash_packet(packet) -> str:
    """
    Compute the hash of a packet

    Args:
        packet (dict): The packet to compute the hash of

    Returns:
        (str): The sha256 hash of the packet
    """
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
    """
    Build a packet with given packet type and content

    Args:
        pkt_type (str): The type of the packet
        pkt_content (str): String of the packet content

    Returns:
        (dict): A packet with the given type and content
    """
    packet = {
        "time": str(time.time()),
        "type": str(pkt_type),
        "content": str(pkt_content),
    }
    hash_str = hash_packet(packet)
    packet["hash"] = hash_str
    return packet


def log_packet_issue(issue_str, pkt_json, computed_hash=None):
    """
    Logs an issue with the given packet

    Args:
        issue_str (str): The issue with the packet
        pkt_json (dict): The packet data
        computed_hash (str): The computed hash of the packet (optional)
    """
    logger.warning("""
Found %s, packet data:
    packet hash: %s
    computed hash: %s
    packet time: %s
    packet type: %s
    packet content: %s""",
                   issue_str,
                   str(pkt_json["hash"]),
                   computed_hash or "N/A",
                   str(pkt_json["time"]),
                   str(pkt_json["type"]),
                   str(pkt_json["content"]))


def pkt_err(err_type, pkt_content):
    """
    Build an error packet with the given error type and content

    Args:
        err_type (str): Type of the error
        pkt_content (str): String of the packet content

    Returns:
        (dict): The error packet
    """
    return build_packet("err:"+err_type, str(pkt_content))


def pkt_confirm(pkt):
    """
    Build a received confirmation packet with the given packet hash as content

    Args:
        pkt (dict): Packet to confirm

    Returns:
        (dict) The confirmation packet
    """
    return build_packet("pkt:recv", str(pkt["hash"]))
