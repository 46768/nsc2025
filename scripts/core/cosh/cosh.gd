class_name COSH
extends RefCounted
## A shell implementation similar to bash
##
## A modular shell implementation allowing
## for hot swappable commands


## Emit when current working directory changes
signal cwd_changed(new_cwd: String)
## Emit when output buffer changed
signal output_changed

# Shell filesystem information
var attached_vfs: VFS
var cwd: String = "/"

# Shell user information
var shell_user: String = "cosh"
var shell_machine: String = "cosine"

# Shell capability information
var module_reg: Dictionary = {}
var command_reg: Dictionary = {}
var signal_reg: Dictionary = {}

var output_buffer: String = ""


func _init(vfs: VFS) -> void:
	attached_vfs = vfs
	
	COSHBuiltins.new().install_module(self)


## Change the virtual filesystem of the shell
func change_vfs(new_vfs: VFS) -> void:
	attached_vfs = new_vfs
	cwd = "/"


# Bind a command string to a callable
#
# Args:
#		cmd (str): Name of the command to bind
#		fn (Callable): The callable to bind the command to
func set_command(cmd: String, fn: Callable) -> void:
	command_reg[cmd] = fn


# Unbind a command from a callable
#
# Args:
#		cmd (str): Name of the command to unbind
func delete_command(cmd: String) -> void:
	command_reg.erase(cmd)


## Run a command with the given arguments
##
## Args:
##		cmd (str): Command to run
##		arg (PackedStringArray): Array of arugments
func run_command(cmd: String, arg: PackedStringArray) -> void:
	var prev_cwd: String = cwd
	var appending_string: String = "[%s@%s:%s]$ %s\n" % [
		shell_user,
		shell_machine,
		cwd,
		cmd + " " + " ".join(arg),
	]

	# Ignore empty command
	if cmd == "":
		pass

	# Run command
	elif cmd in command_reg:
		var cmd_res: String = await command_reg[cmd].call(self, arg)
		appending_string += str(cmd_res)

	# Handle nonexisting commands
	else:
		appending_string += "%s: command not found\n" % cmd
	
	output_buffer += appending_string + "\n"

	if prev_cwd != cwd:
		cwd_changed.emit(cwd)
	
	output_changed.emit()


## Run a command sliently with the given argument
##
## Args:
##		cmd (str): Command to run
##		arg (PackedStringArray): Array of arugments
func run_command_slient(cmd: String, arg: PackedStringArray) -> void:
	var prev_cwd: String = cwd

	if cmd in command_reg:
		await command_reg[cmd].call(self, arg)

	if prev_cwd != cwd:
		cwd_changed.emit(cwd)


# Add a module name to the registry
#
# This is intended to be used only with the module base
# class
#
# Args:
#		module_name (str): Name of the module to add
func add_module_registry(module_name: String) -> void:
	module_reg[module_name] = true


# Remove a module name from the registry
#
# This is intended to be used only with the module base
# class
#
# Args:
#		module_name (str): Name of the module to remove
func remove_module_registry(module_name: String) -> void:
	module_reg.erase(module_name)


# Addd a signal to the registry
#
# This is intended to be used only with the module base
# class
#
# Args:
#		sig_name (str): Name of the signal to add
#		sig (Signal): Signal class to add
func add_signal_registry(sig_name: String, sig: Signal) -> void:
	signal_reg[sig_name] = sig


# Remove a signal from the registry
#
# This is intended to be used only with the module base
# class
#
# Args:
#		sig_name (str): Name of the signal to remove
func remove_signal_registry(sig_name: String) -> void:
	signal_reg.erase(sig_name)
