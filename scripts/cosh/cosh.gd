class_name COSH
extends Object

var attached_vfs: VFS
var parent_dir: Dictionary
var current_dir: Dictionary
var cwd: PackedStringArray

var shell_user: String
var shell_machine: String

var output_buffer: String
var command_reg: Dictionary

func _init(vfs: VFS) -> void:
	attached_vfs = vfs
	parent_dir = vfs.data
	current_dir = vfs.data
	cwd = PackedStringArray([])
	
	shell_user = "john"
	shell_machine = "cosine"
	
	output_buffer = ""
	command_reg = {}
	
	set_command("cd", __cosh_cd)
	set_command("echo", __cosh_echo)
	set_command("clear", __cosh_clear)
	set_command("mkdir", __cosh_mkdir)
	set_command("touch", __cosh_touch)
	set_command("rm", __cosh_rm)
	set_command("ls", __cosh_ls)


func set_command(cmd: String, fn: Callable) -> void:
	command_reg[cmd] = fn


func delete_command(cmd: String) -> void:
	command_reg.erase(cmd)


func run_command(cmd: String, arg: PackedStringArray) -> void:
	var appending_string: String = "[%s@%s:%s]$ %s\n" % [
		shell_user,
		shell_machine,
		get_cwd_string(),
		cmd + " " + " ".join(arg),
	]
	if cmd == "":
		pass
	elif cmd in command_reg:
		appending_string += str(command_reg[cmd].call(arg))
	else:
		appending_string += "%s: command not found\n" % cmd
	output_buffer += appending_string + "\n"


func update_cwd() -> int:
	var temp_current: Dictionary = attached_vfs.get_dir(cwd)
	if temp_current in attached_vfs.DIR_NOT_FOUND:
		return 1
	current_dir = temp_current
	parent_dir = attached_vfs.get_dir(cwd.slice(0, -1))
	return 0


func get_cwd_string() -> String:
	return "/" + "/".join(cwd)


# Builtin programs

func __cosh_cd(child_packed: PackedStringArray) -> String:
	if child_packed.is_empty():
		return "cd: missing path\n"
	
	var child = child_packed[0]
	var new_cwd = cwd.duplicate()
	
	if child == ".":
		return ""
	elif child == "..":
		new_cwd = cwd.slice(0, -1)
	elif child.begins_with("/"):
		new_cwd = attached_vfs.split_path(child)
	else:
		var child_blocks: PackedStringArray = attached_vfs.split_path(child)
		new_cwd.append_array(child_blocks)
	
	if attached_vfs.dir_exists(new_cwd):
		cwd = new_cwd
		update_cwd()
		return ""
	else:
		return "cd: directory not found\n"


func __cosh_echo(text: PackedStringArray):
	return " ".join(text) + "\n"


func __cosh_clear(_unused: PackedStringArray):
	output_buffer = ""
	return ""


func __cosh_mkdir(path_packed: PackedStringArray):
	if path_packed.is_empty():
		return "mkdir: missing path\n"
	
	var path = path_packed[0]
	var new_cwd = cwd.duplicate()
	
	if path.begins_with("/"):
		new_cwd = attached_vfs.split_path(path)
	else:
		var path_blocks: PackedStringArray = attached_vfs.split_path(path)
		new_cwd.append_array(path_blocks)
	
	var mkdir_res: int = attached_vfs.mkdir("/"+"/".join(new_cwd))
	if mkdir_res == attached_vfs.ERR_BLOCK_EXIST:
		return "mkdir: cannot create directory '%s': File exists\n" % path
	else:
		return ""


func __cosh_touch(path: PackedStringArray):
	pass


func __cosh_rm(path: PackedStringArray):
	pass


func __cosh_ls(path_packed: PackedStringArray):
	var path: PackedStringArray
	if path_packed.is_empty():
		path = cwd
	else:
		path = attached_vfs.split_path(path_packed[0])
	var dir: Dictionary = attached_vfs.get_dir(path)
	var ret_string_arr: PackedStringArray = PackedStringArray([])
	for block in dir.keys():
		if dir[block] is Dictionary:
			ret_string_arr.append("[color=7fb4ca]%s[/color]" % block)
		else:
			ret_string_arr.append(block)
	return " ".join(ret_string_arr)
