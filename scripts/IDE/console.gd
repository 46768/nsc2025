extends Node

## Emit when current working directory changes
signal cwd_changed(new_cwd: String)
signal console_initialized(shell: COSH)

@onready var output: RichTextLabel = $ConsoleOutput/ConsoleOutputText
@onready var cmd_input: LineEdit = $ConsoleInput/ConsoleInputLine
@onready var cwd_label: Label = $ConsoleInput/ConsoleCWD/CWDText

var vfs: VFS
var shell: COSH
var ide_initialized: bool = false


func _run_command(input: String) -> void:
	if not ide_initialized:
		return
	if input != "":
		var input_blocks: PackedStringArray = input.split(" ", false)
		await shell.run_command(input_blocks[0], input_blocks.slice(1))
	else:
		await shell.run_command("", [])

	output.text = shell.output_buffer
	cmd_input.text = ""
	cwd_label.text = " [%s@%s: %s]$ " % [shell.shell_user, shell.shell_machine, shell.cwd]


func _on_ide_initialized(ide_vfs: VFS) -> void:
	vfs = ide_vfs
	shell = COSH.new(vfs)
	COSHTestModule.new().install_module(shell)
	COSHPythonModule.new().install_module(shell)
	
	shell.cwd_changed.connect(cwd_changed.emit)
	cwd_label.text = " [%s@%s: %s]$ " % [shell.shell_user, shell.shell_machine, shell.cwd]
	ide_initialized = true


func _on_ide_vfs_changed(new_vfs: VFS) -> void:
	vfs = new_vfs
	shell.change_vfs(new_vfs)


func _on_buffer_initialized(buffer_mgr: BufferManager) -> void:
	COSHEditor.new(buffer_mgr).install_module(shell)
	console_initialized.emit(shell)
