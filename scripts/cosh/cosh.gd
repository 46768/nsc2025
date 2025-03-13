class_name COSH
extends Object

signal cwd_changed(new_cwd: String)

var attached_vfs: VFS
var cwd: String = "/"

var shell_user: String = "cosh"
var shell_machine: String = "cosine"

var module_reg: Dictionary = {}
var command_reg: Dictionary = {}
var signal_reg: Dictionary = {}

var output_buffer: String = ""


func _init(vfs: VFS) -> void:
	attached_vfs = vfs
	
	COSHBuiltins.new().install_module(self)


func set_command(cmd: String, fn: Callable) -> void:
	command_reg[cmd] = fn


func delete_command(cmd: String) -> void:
	command_reg.erase(cmd)


func run_command(cmd: String, arg: PackedStringArray) -> void:
	var prev_cwd = cwd
	var appending_string: String = "[%s@%s:%s]$ %s\n" % [
		shell_user,
		shell_machine,
		cwd,
		cmd + " " + " ".join(arg),
	]
	if cmd == "":
		pass
	elif cmd in command_reg:
		appending_string += str(command_reg[cmd].call(self, arg))
	else:
		appending_string += "%s: command not found\n" % cmd
	output_buffer += appending_string + "\n"
	if prev_cwd != cwd:
		cwd_changed.emit(cwd)


func add_module_registry(module_name: String) -> void:
	module_reg[module_name] = true


func remove_module_registry(module_name: String) -> void:
	module_reg.erase(module_name)


func add_signal_registry(sig_name: String, sig: Signal) -> void:
	signal_reg[sig_name] = sig


func remove_signal_registry(sig_name: String) -> void:
	signal_reg.erase(sig_name)
