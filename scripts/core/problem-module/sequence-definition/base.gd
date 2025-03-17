var types: Dictionary[String, Callable] = {
	"s": str,
	"m": func(x:String)->String: return "!??"+str(x),
	"d": func(x:String)->int: return int(x),
}


func shell(_ram: Dictionary, cmd: String, extra: String = "") -> void:
	var cmd_blocks: PackedStringArray = cmd.split(" ")
	var cmd_cmd: String = cmd_blocks[0]
	var cmd_args: PackedStringArray = cmd_blocks.slice(1)
	cmd_args.append(extra)
	Globals.ide.shell.run_command(cmd_cmd, cmd_args)


func dialogue(_ram: Dictionary, text: String) -> void:
	Dialogue.spawn_dialogue(text)


func set_statement(_ram: Dictionary, text: String) -> void:
	Globals.ide.problem_statement.set_text(text)


func mov(ram: Dictionary, src: Variant, dest: String) -> void:
	if dest.begins_with("!??"):
		ram[dest.right(-3)] = src
	else:
		printerr("mov: invalid address")
