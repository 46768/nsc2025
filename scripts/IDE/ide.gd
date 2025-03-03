extends Control

@export_range(49152, 65535) var server_port: int = 56440

var screen_size: Vector2;

const SIDE_BAR_W_RATIO = 0.3
const SIDE_BAR_H_RATIO = 0.6
const EDITOR_W_RATIO = 1 - SIDE_BAR_W_RATIO
const EDITOR_H_RATIO = SIDE_BAR_H_RATIO
const NOTES_W_RATIO = SIDE_BAR_W_RATIO
const NOTES_H_RATIO = 1 - SIDE_BAR_H_RATIO
const CONSOLE_W_RATIO = EDITOR_W_RATIO
const CONSOLE_H_RATIO = NOTES_H_RATIO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	set_size(screen_size)
	set_position(Vector2.ZERO)
	
	print("setting sidebar")
	$Sidebar.set_position(Vector2.ZERO)
	$Sidebar.set_size(screen_size * Vector2(SIDE_BAR_W_RATIO, SIDE_BAR_H_RATIO))
	$Sidebar.set_sidebar_layout(screen_size * Vector2(SIDE_BAR_W_RATIO, SIDE_BAR_H_RATIO))
	
	print("setting editor")
	$Editor.set_position(screen_size * Vector2(SIDE_BAR_W_RATIO, 0))
	$Editor.set_size(screen_size * Vector2(EDITOR_W_RATIO, EDITOR_H_RATIO))
	
	print("setting console")
	$Console.set_position(screen_size * Vector2(SIDE_BAR_W_RATIO, SIDE_BAR_H_RATIO))
	$Console.set_size(screen_size * Vector2(CONSOLE_W_RATIO, CONSOLE_H_RATIO))
	$Console.set_console_layout(screen_size * Vector2(CONSOLE_W_RATIO, CONSOLE_H_RATIO))
	
	print("setting notes")
	$Notes.set_position(screen_size * Vector2(0, SIDE_BAR_H_RATIO))
	$Notes.set_size(screen_size * Vector2(NOTES_W_RATIO, NOTES_H_RATIO))
	
	print("Hello!")
	var res = PythonBinding.run("res://python-binding/server.py", [
		str(server_port),
		ProjectSettings.globalize_path(PythonBinding.PYTHON3_BIN_PATH),
	])
	
	for i in res:
		print(i)
