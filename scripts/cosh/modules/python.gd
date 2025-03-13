class_name COSHPythonModule
extends COSHModule


func _init() -> void:
	module_name = "Python"
	commands = {
		"python3": request_execution,
		"python": request_execution,
	}
	signals = {}


func request_execution(shell: COSH, args: PackedStringArray) -> String:
	if args.is_empty():
		return "python3: missing file"
	var path: String = args[0]
	var abs_path = path if path.begins_with("/") else VFS.path_join(shell.cwd, path)
	abs_path = VFS.resolve_path(path)
	
	if not shell.attached_vfs.block_exists(abs_path):
		return "python3: file not found"
	
	var code_result: PackedStringArray = await CodeServer.request_execution(
		shell.attached_vfs,
		abs_path
	)
	return code_result[0] + code_result[1]
