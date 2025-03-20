class_name COSHModule
extends Object
## A base shell module implementation
##
## When making a shell module, commands should
## be defined as a function then added to the
## command dictionary in the _init function
## 


var module_name: String = ""
var commands: Dictionary = {}
var signals: Dictionary = {}


## Installs a shell module to the shell
##
## Args:
##		shell (COSH): The shell to install to
func install_module(shell: COSH) -> bool:
	if shell.module_reg.has(module_name):
		return false
	shell.add_module_registry(module_name)
	for cmd: String in commands.keys():
		shell.set_command(cmd, commands[cmd])
	for sig: String in signals.keys():
		shell.add_signal_registry(sig, signals[sig])
	return true


## Uninstalls a shell module to the shell
##
## Args:
##		shell (COSH): The shell to uninstall from
func uninstall_module(shell: COSH) -> bool:
	if not shell.module_reg.has(module_name):
		return false
	shell.remove_module_registry(module_name)
	for cmd: String in commands.keys():
		shell.delete_command(cmd)
	for sig: String in signals.keys():
		shell.remove_signal_registry(sig)
	return true
