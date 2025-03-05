class_name COSHModule
extends Object


var module_name: String = ""
var commands: Dictionary = {}


func install_module(shell: COSH) -> bool:
	if shell.module_reg.has(module_name):
		return false
	shell.add_module_registry(module_name)
	for cmd in commands.keys():
		shell.set_command(cmd, commands[cmd])
	return true


func uninstall_module(shell: COSH) -> bool:
	if not shell.module_reg.has(module_name):
		return false
	shell.remove_module_registry(module_name)
	for cmd in commands.keys():
		shell.delete_command(cmd)
	return true
