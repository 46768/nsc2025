class_name COSHFSIOModule
extends COSHModule


func _init() -> void:
	module_name = "FS IO Module"
	commands = {
		"write": write_file
	}
	signals = {}


func write_file(shell: COSH, args: PackedStringArray) -> String:
	if args.is_empty():
		return "touch: missing file operand\n"
	var path: String = args[0]
	var content: String = " ".join(args.slice(1))
	
	path = path if path.begins_with("/") else VFS.path_join(shell.cwd, path)
	path = VFS.resolve_path(path)
	if not shell.attached_vfs.block_exists(path):
		shell.attached_vfs.write_file(path, content)
	elif not shell.attached_vfs.is_dir(path):
		shell.attached_vfs.write_file(path, content)
	
	shell.attached_vfs.buffer_reload.emit()
	return ""
