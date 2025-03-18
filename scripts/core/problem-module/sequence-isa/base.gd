extends RefCounted
##

var isa_name: StringName = &"BASE"
var types: Dictionary[String, Callable] = {
	"s": str,
	"m": func(x:String)->String: return "@!~"+str(x),
	"d": func(x:String)->int: return int(x),
}


# ###############################
# Shell Interaction
# ###############################

## Invoke a shell command
##
## Args:
##	*args (str): Commands to run
func shell(args: Array) -> void:
	var cmd: String = args[1]
	
	var cmd_blocks: PackedStringArray = cmd.split(" ")
	cmd_blocks.append_array(PackedStringArray(args.slice(2)))
	var cmd_cmd: String = cmd_blocks[0]
	var cmd_args: PackedStringArray = cmd_blocks.slice(1)
	
	await Globals.ide.shell.run_command(cmd_cmd, cmd_args)

## Invoke a shell command sliently
##
## Args:
##	*args (str): Commands to run
func shell_s(args: Array) -> void:
	var cmd: String = args[1]
	
	var cmd_blocks: PackedStringArray = cmd.split(" ")
	cmd_blocks.append_array(PackedStringArray(args.slice(2)))
	var cmd_cmd: String = cmd_blocks[0]
	var cmd_args: PackedStringArray = cmd_blocks.slice(1)
	
	await Globals.ide.shell.run_command_slient(cmd_cmd, cmd_args)


# ###############################
# Memory Management
# ###############################

## Move data into a memory label
##
## Args:
##	[1] (any): Data to store
##	[2] (mem_addr): Memory label for the data
func mov(args: Array) -> void:
	var ram: Dictionary = args[0][1]
	var src: Variant = args[1]
	var dest: String = args[2]
	
	if dest.begins_with("@!~"):
		ram[dest.right(-3)] = src
	else:
		printerr("mov: invalid address")


# ###############################
# Control Flow
# ###############################

## Wait a signal
##
## Args:
##	[1] (signal): Signal to wait for
func wait_sig(args: Array) -> void:
	var sig: Signal = args[1]
	
	await sig
	args[0][0].run()  # Return control to the CPU

## Yield the CPU, can call run to continue running
func cpu_yield(args: Array) -> void:
	# CPU Registers
	args[0][1] |= 0b01

## Halts the CPU, can't call run to continue running
func cpu_halt(args: Array) -> void:
	# Registers
	args[0][1] |= 0b10


# ###############################
# Unsorted
# ###############################

## Spawns a dialogue box
##
## Args:
##	[1] (str): Text of the dialogue
##	[2] (:obj:`Texture2D`, optional): Picture texture of the dialogue
func dialogue(args: Array) -> void:
	var ram: Dictionary = args[0][1]
	var dialogue_text: String = args[1]
	var dialogue_texture: Texture2D = args[2] if len(args) >= 2 else null
	
	var dialogue_hash: String = Dialogue.spawn_dialogue(
			dialogue_text, dialogue_texture)
	var current_dialogue: Node = Dialogue.current_dialogue[dialogue_hash]
	
	ram["latestDialogue"] = current_dialogue
	ram["latestDialogueClosedSig"] = current_dialogue.dialogue_closed
