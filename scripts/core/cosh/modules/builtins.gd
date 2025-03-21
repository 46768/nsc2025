class_name COSHBuiltins
extends COSHModule
## Builtin shell commands, get loaded by a shell on creation by default
##
## Contains commands for basic shell interactions and basic filesystem
## management


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
		"cat": __cosh_cat,
		"exit": __cosh_quit,
	}


# Builtin programs

## Change directory of the shell's current working directory
##
## Args:
##		[0] (str): Path to the new directory, can be relative and absolute
func __cosh_cd(shell: COSH, args: PackedStringArray) -> String:
	if args.is_empty():
		return "cd: missing path\n"
	
	var path: String = args[0]
	var new_cwd: String = shell.cwd
	
	if path.begins_with("/"):
		new_cwd = path
	else:
		new_cwd = VFS.path_join(new_cwd, path)
	new_cwd = VFS.resolve_path(new_cwd)
	
	if not shell.attached_vfs.block_exists(new_cwd):
		return "cd: directory not found\n"
	elif not shell.attached_vfs.is_dir(new_cwd):
		return "cd: %s: Not a directory" % path
	
	shell.cwd = new_cwd
	return ""


## Print out the given arguments separated by space
##
## Args:
##		*args (str): Arguments to print out
func __cosh_echo(_shell: COSH, args: PackedStringArray) -> String:
	return " ".join(args) + "\n"


## Clear the shell's output buffer
##
## Args:
##		[0] (str): Path to the new directory, can be relative and absolute
func __cosh_clear(shell: COSH, _args: PackedStringArray) -> String:
	shell.output_buffer = ""
	return ""


## Create a directory at the given path
##
## Args:
##		[0] (str): Path to the new directory, can be relative and absolute
func __cosh_mkdir(shell: COSH, args: PackedStringArray) -> String:
	if args.is_empty():
		return "mkdir: missing path\n"
	
	var path: String = args[0]
	var dir_path: String = shell.cwd
	
	if path.begins_with("/"):
		dir_path = path
	else:
		dir_path = VFS.path_join(shell.cwd, path)
	dir_path = VFS.resolve_path(dir_path)
	
	var mkdir_res: VFS.RET_CODE = shell.attached_vfs.mkdir(dir_path)
	if mkdir_res == VFS.RET_CODE.ERR:
		return "mkdir: cannot create directory '%s': File exists\n" % path
	else:
		return ""


## Create a new file if file does not exist
##
## Args:
##		[0] (str): Path to the file to create, does nothing if file exists
func __cosh_touch(shell: COSH, args: PackedStringArray) -> String:
	if args.is_empty():
		return "touch: missing file operand\n"
	var path: String = args[0]
	path = path if path.begins_with("/") else VFS.path_join(shell.cwd, path)
	path = VFS.resolve_path(path)
	if not shell.attached_vfs.block_exists(path):
		shell.attached_vfs.write_file(path, "")
	
	return ""


## Delete a file or a directory from the filesystem
##
## To delete a directory, a `-r` flag must be used
##
## Args:
##		[0] (str): Path to the file/directory to delete
##		[flag] ('-r'): Delete recursively
func __cosh_rm(shell: COSH, args: PackedStringArray) -> String:
	if args.is_empty():
		return "rm: missing operand\n"
	var path: String = args[0]
	var flags: String = ""
	if "-r" in args:
		flags = args[0]
		path = args[1]
	path = path if path.begins_with("/") else VFS.path_join(shell.cwd, path)
	path = VFS.resolve_path(path)
	if path == "/":
		return "rm: [color=red]Error: Deleting / will cause irreversable damage to the file system[/color]\n"
	var is_dir: bool = shell.attached_vfs.is_dir(path)
	if "r" not in flags and is_dir:
		return "rm: cannot remove '%s': Is a directory" % path
	
	var ret_code: VFS.RET_CODE = shell.attached_vfs.delete_block(path)
	if ret_code == VFS.RET_CODE.ERR:
		return "rm: cannot remove '%s': No such file or directory" % path
	return ""


## List content of a directory, defaults to current directory if not given
##
## Args:
##		[0] (:obj:`str`, optional): Path to the directory, defaults to cwd
func __cosh_ls(shell: COSH, args: PackedStringArray) -> String:
	var path: String = shell.cwd if args.is_empty() else args[0]
	path = path if path.begins_with("/") else VFS.path_join(shell.cwd, path)
	path = VFS.resolve_path(path)
	var dir: Dictionary = shell.attached_vfs.get_block(path)
	var ret_string_arr: PackedStringArray = PackedStringArray([])
	for block: String in (dir.content as Dictionary).keys():
		var basename: String = VFS.get_basename(block)
		if shell.attached_vfs.is_dir(block):
			ret_string_arr.append("[color=7fb4ca]%s[/color]" % basename)
		else:
			ret_string_arr.append(basename)
	return " ".join(ret_string_arr) + ("" if ret_string_arr.is_empty() else "\n")


## Prints out the content of a file
##
## Args:
##		[0] (str): Path to the file to print the content of
func __cosh_cat(shell: COSH, args: PackedStringArray) -> String:
	if args.is_empty():
		return "cat: missing path\n"
	var path: String = args[0]
	path = path if path.begins_with("/") else VFS.path_join(shell.cwd, path)
	var abs_path: String = path
	path = VFS.resolve_path(path)
	if not shell.attached_vfs.block_exists(path):
		return "cat: %s: No such file\n" % abs_path
	var is_dir: bool = shell.attached_vfs.is_dir(path)

	if is_dir:
		return "cat: '%s': Is a directory\n" % abs_path
	return shell.attached_vfs.read_file(path) + "\n"


## Exits the **game**, not the shell
func __cosh_quit(_shell: COSH, _args: PackedStringArray) -> String:
	Globals.close_game()
	return ""
