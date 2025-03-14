extends Control


## Emit once after the IDE is initialized
signal ide_initialized(ide_vfs: VFS)

@export_range(49152, 65535) var server_port: int = 56440
@export_range(0, 100) var margin: int = 10

var sidebar_split: VSplitContainer
var editor_split: VSplitContainer
var vfs: VFS


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
	sidebar_split = $Margin/VerticalSplit/SidebarSplit
	editor_split = $Margin/VerticalSplit/EditorSplit
	
	$Margin.add_theme_constant_override("margin_bottom", margin)
	$Margin.add_theme_constant_override("margin_left", margin)
	$Margin.add_theme_constant_override("margin_top", margin)
	$Margin.add_theme_constant_override("margin_right", margin)
	
	vfs = VFS.new()
	vfs.set_name("ide_custom")
	
	Globals.screen_resized.connect(resize)
	sidebar_split.dragged.connect(sidebar_to_editor_sync)
	editor_split.dragged.connect(editor_to_sidebar_sync)
	
	ide_initialized.emit(vfs)
