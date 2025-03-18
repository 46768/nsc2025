class_name COSHModule
extends Object


var module_name: String = ""
var commands: Dictionary = {}
var signals: Dictionary = {}


func install_module(shell: COSH) -> bool:
	if shell.module_reg.has(module_name):
		return false
	shell.add_module_registry(module_name)
	for cmd: String in commands.keys():
		shell.set_command(cmd, commands[cmd])
	for sig: String in signals.keys():
		shell.add_signal_registry(sig, signals[sig])
	return true


func uninstall_module(shell: COSH) -> bool:
	if not shell.module_reg.has(module_name):
		return false
	shell.remove_module_registry(module_name)
	for cmd: String in commands.keys():
		shell.delete_command(cmd)
	for sig: String in signals.keys():
		shell.remove_signal_registry(sig)
	return true
