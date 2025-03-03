extends Control

@export_range(49152, 65535) var server_port: int = 56440

var sidebar_split: VSplitContainer
var editor_split: VSplitContainer

func sidebar_to_editor_sync(offset: int) -> void:
	editor_split.split_offset = offset


func editor_to_sidebar_sync(offset: int) -> void:
	sidebar_split.split_offset = offset


func resize() -> void:
	set_size(get_viewport_rect().size)
	set_position(Vector2.ZERO)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resize()
	sidebar_split = $MarginContainer/VerticalSplit/SidebarSplit
	editor_split = $MarginContainer/VerticalSplit/EditorSplit
	sidebar_split.dragged.connect(sidebar_to_editor_sync)
	editor_split.dragged.connect(editor_to_sidebar_sync)
	get_tree().get_root().size_changed.connect(resize)
	pass
