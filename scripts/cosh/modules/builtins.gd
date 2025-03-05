class_name COSHBuiltins
extends COSHModule


func _init() -> void:
	module_name = "Builtins"
	commands = {
		"cd": __cosh_cd,
		"echo": __cosh_echo,
		"clear": __cosh_clear,
		"mkdir": __cosh_mkdir,
		"touch": __cosh_touch,
		"rm": __cosh_rm,
		"ls": __cosh_ls,
	}


# Builtin programs

func __cosh_cd(shell: COSH, args: PackedStringArray) -> String:
	if args.is_empty():
		return "cd: missing path\n"
	
	var path = args[0]
	var new_cwd = shell.cwd
	
	if path == ".":
		return ""
	elif path == "..":
		new_cwd = shell.attached_vfs.get_parent(shell.cwd)
	elif path.begins_with("/"):
		new_cwd = path
	else:
		new_cwd += ("" if shell.cwd.ends_with("/") else "/") + path
	
	var new_cwd_is_dir: bool = (shell.attached_vfs.get_block(new_cwd).type as VFS.FileType) == VFS.FileType.DIRECTORY
	if shell.attached_vfs.block_exists(new_cwd) and new_cwd_is_dir:
		shell.cwd = new_cwd
		return ""
	elif not new_cwd_is_dir:
		return "cd: %s: Not a directory" % path
	else:
		return "cd: directory not found\n"


func __cosh_echo(_shell: COSH, args: PackedStringArray):
	return " ".join(args) + "\n"


func __cosh_clear(shell: COSH, _args: PackedStringArray):
	shell.output_buffer = ""
	return ""


func __cosh_mkdir(shell: COSH, args: PackedStringArray):
	if args.is_empty():
		return "mkdir: missing path\n"
	
	var path: String = args[0]
	var dir_path: String = shell.cwd
	
	if path.begins_with("/"):
		dir_path = path
	else:
		dir_path += ("" if shell.cwd.ends_with("/") else "/") + path
	
	var mkdir_res: VFS.RET_CODE = shell.attached_vfs.mkdir(dir_path)
	if mkdir_res == shell.attached_vfs.RET_CODE.ERR:
		return "mkdir: cannot create directory '%s': File exists\n" % path
	else:
		return ""


func __cosh_touch(shell: COSH, args: PackedStringArray):
	if args.is_empty():
		return "touch: missing file operand\n"
	var path: String = args[0]
	path = path if path.begins_with("/") else shell.cwd + ("" if shell.cwd.ends_with("/") else "/") + path
	if not shell.attached_vfs.block_exists(path):
		shell.attached_vfs.write_file(path, "")
	
	return ""


func __cosh_rm(shell: COSH, args: PackedStringArray):
	if args.is_empty():
		return "rm: missing operand\n"
	var path: String = args[0]
	var flags: String = ""
	if "-r" in args:
		flags = args[0]
		path = args[1]
	path = path if path.begins_with("/") else shell.cwd + ("" if shell.cwd.ends_with("/") else "/") + path
	if path == "/":
		return "rm: [color=red]Error: Deleting / will cause irreversable damage to the file system[/color]\n"
	var is_dir: bool = (shell.attached_vfs.get_block(path).type as VFS.FileType) == VFS.FileType.DIRECTORY
	if "r" not in flags and is_dir:
		return "rm: cannot remove '%s': Is a directory" % path
	
	var ret_code: VFS.RET_CODE = shell.attached_vfs.delete_block(path)
	if ret_code == VFS.RET_CODE.ERR:
		return "rm: cannot remove '%s': No such file or directory" % path
	return ""


func __cosh_ls(shell: COSH, args: PackedStringArray):
	var path: String = shell.cwd if args.is_empty() else args[0]
	path = path if path.begins_with("/") else shell.cwd + ("" if shell.cwd.ends_with("/") else "/") + path
	var dir: Dictionary = shell.attached_vfs.get_block(path)
	var ret_string_arr: PackedStringArray = PackedStringArray([])
	for block in (dir.content as Dictionary).keys():
		var basename: String = shell.attached_vfs.get_basename(block)
		if (shell.attached_vfs.get_block(block).type as VFS.FileType) == VFS.FileType.DIRECTORY:
			ret_string_arr.append("[color=7fb4ca]%s[/color]" % basename)
		else:
			ret_string_arr.append(basename)
	return " ".join(ret_string_arr) + ("" if ret_string_arr.is_empty() else "\n")
