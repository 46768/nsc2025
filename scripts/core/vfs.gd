class_name VFS
extends Object

const DIR_NOT_FOUND: Dictionary = {"NOT_FOUND": 1}

const ERR_BLOCK_EXIST: int = 1
const ERR_BLOCK_NOT_EXIST: int = 2

var data: Dictionary

func _get_dir(path_blocks: PackedStringArray) -> Dictionary:
	var current: Dictionary = data
	
	for block_idx in range(path_blocks.size()):
		var block = path_blocks[block_idx]
		if current.has(block) and current[block] is String:
			return DIR_NOT_FOUND
		if current.has(block) and (block_idx == path_blocks.size()-1):
			return DIR_NOT_FOUND
		if not current.has(block):
			return DIR_NOT_FOUND
		current = current[block]
	return current

func mkdir(path: String) -> int:
	var path_blocks: PackedStringArray = path.split("/")
	var parent_dir: Dictionary = _get_dir(path_blocks.slice(0, -1))
	if parent_dir in DIR_NOT_FOUND:
		return ERR_BLOCK_NOT_EXIST
	if parent_dir.has(path_blocks[-1]):
		return ERR_BLOCK_EXIST
	
	parent_dir[path_blocks[-1]] = {}
	return 0


func write_file(path: String, content: String) -> int:
	var path_blocks: PackedStringArray = path.split("/")
	var parent_dir: Dictionary = _get_dir(path_blocks.slice(0, -1))
	if parent_dir in DIR_NOT_FOUND:
		return ERR_BLOCK_NOT_EXIST
	
	parent_dir[path_blocks[path_blocks.size()-1]] = content
	return 0


func read_file(path: String) -> String:
	var path_blocks: PackedStringArray = path.split("/")
	var parent_dir: Dictionary = _get_dir(path_blocks.slice(0, -1))
		
	return parent_dir[path_blocks[-1]]


func delete_block(path: String) -> int:
	var path_blocks: PackedStringArray = path.split("/")
	var parent_dir: Dictionary = _get_dir(path_blocks.slice(0, -1))
	if parent_dir in DIR_NOT_FOUND:
		return ERR_BLOCK_NOT_EXIST
	
	parent_dir.erase(path_blocks[-1])
	return 0


func _init() -> void:
	data = {}
