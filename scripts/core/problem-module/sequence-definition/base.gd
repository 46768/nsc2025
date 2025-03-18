var isa_name: StringName = &"BASE"
var types: Dictionary[String, Callable] = {
	"s": str,
	"m": func(x:String)->String: return "!??"+str(x),
	"d": func(x:String)->int: return int(x),
}


func shell(args: Array) -> void:
	var cmd: String = args[1]
	var cmd_blocks: PackedStringArray = cmd.split(" ")
	cmd_blocks.append_array(PackedStringArray(args.slice(2)))
	var cmd_cmd: String = cmd_blocks[0]
	var cmd_args: PackedStringArray = cmd_blocks.slice(1)
	await Globals.ide.shell.run_command(cmd_cmd, cmd_args)


func shell_s(args: Array) -> void:
	var cmd: String = args[1]
	var cmd_blocks: PackedStringArray = cmd.split(" ")
	cmd_blocks.append_array(PackedStringArray(args.slice(2)))
	var cmd_cmd: String = cmd_blocks[0]
	var cmd_args: PackedStringArray = cmd_blocks.slice(1)
	await Globals.ide.shell.run_command_slient(cmd_cmd, cmd_args)


func wait_sig(args: Array) -> void:
	var sig: Signal = args[1]
	await sig
	args[0][0].run()  # Return control to the CPU


func dialogue(args: Array) -> void:
	var dialogue_texture: Texture2D = args[2] if len(args) >= 2 else null
	var dialogue_hash: String = Dialogue.spawn_dialogue(args[1], dialogue_texture)
	args[0][1]["latestDialogue"] = Dialogue.current_dialogue[dialogue_hash]
	args[0][1]["latestDialogueClosedSig"] = Dialogue.current_dialogue[dialogue_hash].dialogue_closed


func set_statement(args: Array) -> void:
	Globals.ide.problem_statement.set_text(args[1])


func highlight_buffer(args: Array) -> void:
	var buffer_mgr: BufferManager = Globals.ide.buffer_mgr
	buffer_mgr.highlight_current_buffer.callv(args.slice(1))

func clear_highlight(_args: Array) -> void:
	var buffer_mgr: BufferManager = Globals.ide.buffer_mgr
	buffer_mgr.clear_current_buffer_highlight()


func mov(args: Array) -> void:
	var ram: Dictionary = args[0][1]
	var src: Variant = args[1]
	var dest: String = args[2]
	
	if dest.begins_with("!??"):
		ram[dest.right(-3)] = src
	else:
		printerr("mov: invalid address")


# ###############################
# Control flow
# ###############################

func cpu_yield(args: Array) -> void:
	args[0][1] |= 0b01


func cpu_halt(args: Array) -> void:
	args[0][1] |= 0b10
