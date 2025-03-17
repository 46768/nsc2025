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
	Globals.ide.shell.run_command(cmd_cmd, cmd_args)


func dialogue(args: Array) -> void:
	Dialogue.spawn_dialogue(args[1])


func set_statement(args: Array) -> void:
	Globals.ide.problem_statement.set_text(args[1])


func mov(args: Array) -> void:
	var ram: Dictionary = args[0]
	var src: Variant = args[1]
	var dest: String = args[2]
	
	if dest.begins_with("!??"):
		ram[dest.right(-3)] = src
	else:
		printerr("mov: invalid address")
