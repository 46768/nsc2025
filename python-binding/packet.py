import hashlib
import time
import logging

logger = logging.getLogger(__name__)


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


def log_packet_issue(issue_str, pkt_json, computed_hash=None):
    logger.warning("""
Found unknown type, packet data:
    packet hash: %s
    computed hash: %s
    packet time: %s
    packet type: %s
    packet content: %s""",
                   str(pkt_json["hash"]),
                   computed_hash or "N/A",
                   str(pkt_json["time"]),
                   str(pkt_json["type"]),
                   str(pkt_json["content"]))


def pkt_err(err_type, pkt_content):
    return build_packet("err:"+err_type, pkt_content)


def pkt_confirm(pkt):
    return build_packet("pkt:recv", str(pkt["hash"]))
