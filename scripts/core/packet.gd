extends Node


func _ready() -> void:
	pass


func hash_packet(packet: Dictionary) -> String:
	var base_str = (str(packet["time"])
				+ str(packet["type"])
				+ str(packet["content"]))
	return base_str.sha256_text()


func build_packet(type: String, content: String) -> Dictionary:
	var packet = {
		"time": str(Time.get_unix_time_from_system()),
		"type": type,
		"content": content,
	}
	packet["hash"] = hash_packet(packet)
	return packet


func format_packet_http(pkt: Dictionary) -> Dictionary:
	var http_pkt: Dictionary = {
		"headers": PackedStringArray([
			"Packet-Time: %s" % pkt["time"],
			"Packet-Type: %s" % pkt["type"],
			"Packet-Hash: %s" % pkt["hash"],
			"Content-Type: application/json",
		]),
		"body": pkt["content"]
	}
	return http_pkt
