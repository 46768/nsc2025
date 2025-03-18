extends RefCounted
##

var isa_name: StringName = &"BASE"
var _mem_addr_prefix: String = "@!~"
var types: Dictionary[String, Callable] = {
	"s": str,
	"m": func(x:String)->String: return _mem_addr_prefix+str(x),
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
	
	if dest.begins_with(_mem_addr_prefix):
		ram[dest.right(-3)] = src
	else:
		printerr("mov: invalid address")


# ###############################
# Math
# ###############################

func add(args: Array) -> void:
	var ram: Dictionary = args[0][1]
	var val: int = args[1]
	var target: String = args[2]
	
	if not target.begins_with(_mem_addr_prefix):
		printerr("add: invalid address")
		return
	elif ram[target.right(-3)] is not int:
		printerr("add: wrong memory type")
		return
	
	ram[target.right(-3)] += val
	if ram[target.right(-3)] == 0:
		args[0][0].flags |= 0b100
	else:
		args[0][0].flags &= ~0b100

func sub(args: Array) -> void:
	var ram: Dictionary = args[0][1]
	var val: int = args[1]
	var target: String = args[2]
	
	if not target.begins_with(_mem_addr_prefix):
		printerr("sub: invalid address")
		return
	elif ram[target.right(-3)] is not int:
		printerr("sub: wrong memory type")
		return
	
	ram[target.right(-3)] -= val
	if ram[target.right(-3)] == 0:
		args[0][0].flags |= 0b100
	else:
		args[0][0].flags &= ~0b100

func mul(args: Array) -> void:
	var ram: Dictionary = args[0][1]
	var val: int = args[1]
	var target: String = args[2]
	
	if not target.begins_with(_mem_addr_prefix):
		printerr("mul: invalid address")
		return
	elif ram[target.right(-3)] is not int:
		printerr("mul: wrong memory type")
		return
	
	ram[target.right(-3)] *= val
	if ram[target.right(-3)] == 0:
		args[0][0].flags |= 0b100
	else:
		args[0][0].flags &= ~0b100

func div(args: Array) -> void:
	var ram: Dictionary = args[0][1]
	var val: int = args[1]
	var target: String = args[2]
	
	if not target.begins_with(_mem_addr_prefix):
		printerr("div: invalid address")
		return
	elif ram[target.right(-3)] is not int:
		printerr("div: wrong memory type")
		return
	
	ram[target.right(-3)] /= val
	if ram[target.right(-3)] == 0:
		args[0][0].flags |= 0b100
	else:
		args[0][0].flags &= ~0b100

func inc(args: Array) -> void:
	var ram: Dictionary = args[0][1]
	var target: String = args[1]
	
	if not target.begins_with(_mem_addr_prefix):
		printerr("inc: invalid address")
		return
	elif ram[target.right(-3)] is not int:
		printerr("inc: wrong memory type")
		return
	
	ram[target.right(-3)] += 1
	if ram[target.right(-3)] == 0:
		args[0][0].flags |= 0b100
	else:
		args[0][0].flags &= ~0b100

func dec(args: Array) -> void:
	var ram: Dictionary = args[0][1]
	var target: String = args[1]
	
	if not target.begins_with(_mem_addr_prefix):
		printerr("dec: invalid address")
		return
	elif ram[target.right(-3)] is not int:
		printerr("dec: wrong memory type")
		return
	
	ram[target.right(-3)] -= 1
	if ram[target.right(-3)] == 0:
		args[0][0].flags |= 0b100
	else:
		args[0][0].flags &= ~0b100


# ###############################
# Comparasions
# ###############################

func cmp(args: Array) -> void:
	var lhs: int = args[1]
	var rhs: int = args[2]
	
	if lhs == rhs:
		args[0][0].flags |= 0b100
	else:
		args[0][0].flags &= ~0b100
	
	# Running `sub` then check for sign
	if lhs < rhs:
		args[0][0].flags |= 0b1000
	else:
		args[0][0].flags &= ~0b1000


# ###############################
# Control Flow
# ###############################

func jmp(args: Array) -> void:
	var cpu: SequenceCPU = args[0][0]
	var target: int = args[1]
	
	cpu.instruction_ptr = target

func je(args: Array) -> void:
	var cpu: SequenceCPU = args[0][0]
	var flags: int = cpu.flags
	var target: int = args[1]
	
	if (flags >> 2) & 0b1 == 1:
		cpu.instruction_ptr = target

func jg(args: Array) -> void:
	var cpu: SequenceCPU = args[0][0]
	var flags: int = cpu.flags
	var target: int = args[1]
	
	if (flags >> 3) & 0b1 == 0:
		cpu.instruction_ptr = target

func jng(args: Array) -> void:
	var cpu: SequenceCPU = args[0][0]
	var flags: int = cpu.flags
	var target: int = args[1]
	
	if (flags >> 3) & 0b1 == 1:
		cpu.instruction_ptr = target

func jl(args: Array) -> void:
	jng(args)

func jnl(args: Array) -> void:
	jg(args)

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
	args[0][0].flags |= 0b01

## Halts the CPU, can't call run to continue running
func cpu_halt(args: Array) -> void:
	# Registers
	args[0][0].flags |= 0b10


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
	var dialogue_text: String = str(args[1])
	var dialogue_texture: Texture2D = args[2] if len(args) >= 3 else null
	
	var dialogue_hash: String = Dialogue.spawn_dialogue(
			dialogue_text, dialogue_texture)
	var current_dialogue: Node = Dialogue.current_dialogue[dialogue_hash]
	
	ram["latestDialogue"] = current_dialogue
	ram["latestDialogueClosedSig"] = current_dialogue.dialogue_closed
