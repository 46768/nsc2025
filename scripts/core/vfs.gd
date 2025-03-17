class_name VFS
extends Object

signal data_changed
signal buffer_reload
var data_changed_connected: Array

enum RET_CODE { SUCCESS, ERR }
enum FileType { FILE, DIRECTORY }

var data: Dictionary


func _init(init_data: Dictionary = {}) -> void:
	data = init_data.duplicate(true)
	data_changed_connected = []
	if not block_exists("/"):
		data["/"] = _create_block(VFS.FileType.DIRECTORY)


static func _create_block(ftype: FileType) -> Dictionary:
	var block_content: Variant
	if ftype == FileType.FILE:
		block_content = ""
	else:
		block_content = {}
	return {
		type = ftype,
		content = block_content
	}


static func path_join(path1: String, path2: String) -> String:
	return path1 + ("" if path1.ends_with("/") else "/") + path2


static func get_parent(path: String) -> String:
	return "/"+"/".join(path.split("/", false).slice(0, -1))


static func get_basename(path: String) -> String:
	return path.split("/", false)[-1]


static func resolve_path(path: String) -> String:
	var blocks: PackedStringArray = PackedStringArray([])
	var path_blocks: PackedStringArray = path.split("/", false)
	for block: String in path_blocks:
		if block == ".":
			pass
		elif block == "..":
			blocks = blocks.slice(0, -1)
		else:
			blocks.append(block)
	return "/" + "/".join(blocks)


func set_name(name: String) -> void:
	data["name"] = name
func get_name() -> String:
	return data.get("name", ":notfound:")


func block_exists(path: String) -> bool:
	return data.has(path)


func is_dir(path: String) -> bool:
	if not block_exists(path):
		return false
	return (get_block(path).type as VFS.FileType) == VFS.FileType.DIRECTORY


func get_block(path: String) -> Dictionary:
	return data[path]


func delete_block(path: String) -> RET_CODE:
	if not block_exists(path):
		return RET_CODE.ERR
	if path == "/":
		return RET_CODE.ERR
	var bfs_queue: PackedStringArray = PackedStringArray([path])
	while not bfs_queue.is_empty():
		var current_path: String = bfs_queue[0]
		bfs_queue.remove_at(0)
		var current_block: Dictionary = get_block(current_path)
		if (current_block.type as FileType) == FileType.DIRECTORY:
			bfs_queue.append_array((current_block.content as Dictionary).keys())
		data.erase(current_path)
	(get_block(get_parent(path)).content as Dictionary).erase(path)
	data_changed.emit()
	
	return RET_CODE.SUCCESS


func mkdir(path: String) -> RET_CODE:
	var parent_path: String = get_parent(path)
	if block_exists(path):
		return RET_CODE.ERR
	if not block_exists(parent_path):
		mkdir(parent_path)
	var parent: Dictionary = get_block(parent_path)
	if parent.type == FileType.FILE:
		return RET_CODE.ERR
	
	data[path] = _create_block(FileType.DIRECTORY)
	parent.content[path] = true # Unused value to add key to dict
	data_changed.emit()
	
	return RET_CODE.SUCCESS


func write_file(path: String, content: String) -> RET_CODE:
	var parent_path: String = get_parent(path)
	if not block_exists(parent_path):
		mkdir(parent_path)
	var parent: Dictionary = get_block(parent_path)
	if (parent.type as FileType) == FileType.FILE:
		return RET_CODE.ERR
	if not block_exists(path):
		data[path] = _create_block(FileType.FILE)
		parent.content[path] = true
	var file: Dictionary = get_block(path)
	if (file.type as FileType) == FileType.DIRECTORY:
		return RET_CODE.ERR
	file.content = content
	data_changed.emit()
	
	return RET_CODE.SUCCESS


func read_file(path: String) -> String:
	if not block_exists(path):
		return ""
	var file: Dictionary = get_block(path)
	if (file.type as FileType) == FileType.DIRECTORY:
		return ""
	
	return file.content
