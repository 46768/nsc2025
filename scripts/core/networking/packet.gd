extends Node


func _ready() -> void:
	pass


func hash_packet(packet: Dictionary) -> String:
	var base_str: String = (str(packet["headers"]["p-time"])
							+ str(packet["headers"]["p-type"])
							+ str(packet["content"]))
	return base_str.sha256_text()


func build_packet(
		url: String,
		type: String,
		code: int,
		content: Dictionary) -> Dictionary:
	var packet: Dictionary = {
		"url": url,
		"code": code,
		"headers": {
			"p-time": str(Time.get_unix_time_from_system()),
			"p-type": type,
		},
		"content": JSON.stringify(content),
	}
	packet["headers"]["p-hash"] = hash_packet(packet)
	packet["headers"]["content-length"] = len(packet["content"])
	return packet


func decode_packet(
		url: String,
		code: int,
		headers: PackedStringArray,
		content: String) -> Dictionary:
	var time_header: String = "pkt:404"
	var type_header: String = "pkt:404"
	var hash_header: String = "pkt:404"
	
	for header: String in headers:
		if header.begins_with("p-time"):
			time_header = header
		elif header.begins_with("p-type"):
			type_header = header
		elif header.begins_with("p-hash"):
			hash_header = header
	
	var http_pkt: Dictionary = {
		"url": url,
		"code": code,
		"headers": {
			"p-time": time_header.split(": ")[-1],
			"p-type": type_header.split(": ")[-1],
			"p-hash": hash_header.split(": ")[-1],
		},
		"content": content
	}
	return http_pkt
