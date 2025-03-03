extends Control

@export_range(49152, 65535) var server_port: int = 56440
@export_range(0.1, 0.9, 0.1) var sidebar_w_ratio = 0.3
@export_range(0.1, 0.9, 0.1) var sidebar_h_ratio = 0.6
@export_range(0.01, 0.1, 0.01) var margin = 0.05


func setup_layout(screen_size: Vector2) -> void:
	var container_size = screen_size * (Vector2(1, 1) - (2 * Vector2(margin, margin)))
	var sidebar_ratio: Vector2 = Vector2(sidebar_w_ratio, sidebar_h_ratio)
	var editor_ratio: Vector2 = Vector2(1, 0) - sidebar_ratio * Vector2(1, -1)
	var console_ratio: Vector2 = Vector2(1, 1) - sidebar_ratio
	var notes_ratio: Vector2 = Vector2(0, 1) - sidebar_ratio * Vector2(-1, 1)
	var obj_offset: Vector2 = screen_size * Vector2(margin, margin)

	print(screen_size)
	print(container_size)
	print(sidebar_ratio)
	print(editor_ratio)
	print(console_ratio)
	print(notes_ratio)
	set_size(screen_size)
	set_position(Vector2.ZERO)
	
	$Sidebar.set_position(obj_offset)
	$Sidebar.set_size(container_size * sidebar_ratio)
	$Sidebar.setup_layout($Sidebar.size)
	
	$Editor.set_position(($Sidebar.size * Vector2(1, 0)) + obj_offset)
	$Editor.set_size(container_size * editor_ratio)
	
	$Console.set_position($Sidebar.size + obj_offset)
	$Console.set_size(container_size * console_ratio)
	$Console.setup_layout($Console.size)
	
	$Notes.set_position(($Sidebar.size * Vector2(0, 1)) + obj_offset)
	$Notes.set_size(container_size * notes_ratio)
	
	$IDEPanel.set_position(Vector2.ZERO)
	$IDEPanel.set_size(screen_size)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_layout(get_viewport_rect().size)
	
	print("Hello!")
	var res = PythonBinding.run("res://python-binding/server.py", [
		str(server_port),
		ProjectSettings.globalize_path(PythonBinding.PYTHON3_BIN_PATH),
	])
	
	for i in res:
		print(i)
