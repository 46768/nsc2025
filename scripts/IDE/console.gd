extends Node


var vfs: VFS
var shell: COSH
var output: RichTextLabel
var cmd_input: LineEdit
var cwd_label: Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vfs = VFS.new()
	shell = COSH.new(vfs)
	COSHTestModule.new().install_module(shell)
	
	output = $ConsoleOutput/ConsoleOutputText
	cmd_input = $ConsoleInput/ConsoleInputLine
	cwd_label = $ConsoleInput/ConsoleCWD/CWDText
	
	cwd_label.text = " [%s@%s: %s]$ " % [shell.shell_user, shell.shell_machine, shell.cwd]


func _run_command(input: String) -> void:
	if input != "":
		var input_blocks: PackedStringArray = input.split(" ", false)
		shell.run_command(input_blocks[0], input_blocks.slice(1))
	else:
		shell.run_command("", [])
	output.text = shell.output_buffer
	cmd_input.text = ""
	cwd_label.text = " [%s@%s: %s]$ " % [shell.shell_user, shell.shell_machine, shell.cwd]
