extends Node

## Emit when current working directory changes
signal cwd_changed(new_cwd: String)

var vfs: VFS
var shell: COSH
var output: RichTextLabel
var cmd_input: LineEdit
var cwd_label: Label
var ide_initialized: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	output = $ConsoleOutput/ConsoleOutputText
	cmd_input = $ConsoleInput/ConsoleInputLine
	cwd_label = $ConsoleInput/ConsoleCWD/CWDText


func _run_command(input: String) -> void:
	if not ide_initialized:
		return
	if input != "":
		var input_blocks: PackedStringArray = input.split(" ", false)
		shell.run_command(input_blocks[0], input_blocks.slice(1))
	else:
		shell.run_command("", [])
	output.text = shell.output_buffer
	cmd_input.text = ""
	cwd_label.text = " [%s@%s: %s]$ " % [shell.shell_user, shell.shell_machine, shell.cwd]


func _on_ide_initialized(ide_vfs: VFS) -> void:
	vfs = ide_vfs
	shell = COSH.new(vfs)
	COSHTestModule.new().install_module(shell)
	
	shell.cwd_changed.connect(cwd_changed.emit)
	cwd_label.text = " [%s@%s: %s]$ " % [shell.shell_user, shell.shell_machine, shell.cwd]
	ide_initialized = true


func _on_editor_initialized(editor_mgr: EditorManager) -> void:
	COSHEditor.new(editor_mgr).install_module(shell)
