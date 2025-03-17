extends Control


## Emit once after the IDE is initialized
signal ide_initialized(ide_vfs: VFS)
## Emit when VFS changes
signal ide_vfs_changed(new_vfs: VFS)

@export_range(49152, 65535) var server_port: int = 56440
@export_range(0, 100) var outer_margin: int = 10
@export_range(0, 100) var inner_margin: int = 10

@onready var sidebar_split: VSplitContainer = (
		$OuterMargin/PanelContainer/InnerMargin/VerticalSplit/SidebarSplit)
@onready var editor_split: VSplitContainer = (
		$OuterMargin/PanelContainer/InnerMargin/VerticalSplit/EditorSplit)
@onready var console: VBoxContainer = (
		$OuterMargin/PanelContainer/InnerMargin/VerticalSplit/EditorSplit/Console)
@onready var buffer_tabs: TabContainer = (
		$OuterMargin/PanelContainer/InnerMargin/VerticalSplit/EditorSplit/BufferTabs)

var vfs: VFS = null
var shell: COSH = null
var buffer_mgr: BufferManager = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_resize()
	
	$OuterMargin.add_theme_constant_override("margin_bottom", outer_margin)
	$OuterMargin.add_theme_constant_override("margin_left", outer_margin)
	$OuterMargin.add_theme_constant_override("margin_top", outer_margin)
	$OuterMargin.add_theme_constant_override("margin_right", outer_margin)
	
	$OuterMargin/PanelContainer/InnerMargin.add_theme_constant_override("margin_bottom", inner_margin)
	$OuterMargin/PanelContainer/InnerMargin.add_theme_constant_override("margin_left", inner_margin)
	$OuterMargin/PanelContainer/InnerMargin.add_theme_constant_override("margin_top", inner_margin)
	$OuterMargin/PanelContainer/InnerMargin.add_theme_constant_override("margin_right", inner_margin)
	
	vfs = VFS.new()
	vfs.set_name("ide_custom")
	
	Globals.screen_resized.connect(_resize)
	sidebar_split.dragged.connect(_sidebar_to_editor_sync)
	editor_split.dragged.connect(_editor_to_sidebar_sync)
	console.console_initialized.connect(_on_console_initialized)
	buffer_tabs.buffer_tabs_initialized.connect(_on_buffer_initialized)
	
	Globals.ide = self
	ide_initialized.emit(vfs)


func _sidebar_to_editor_sync(offset: int) -> void:
	editor_split.split_offset = offset


func _editor_to_sidebar_sync(offset: int) -> void:
	sidebar_split.split_offset = offset


func _on_buffer_initialized(buffer_manager: BufferManager) -> void:
	buffer_mgr = buffer_manager


func _on_console_initialized(console_shell: COSH) -> void:
	shell = console_shell


func _resize() -> void:
	set_size(get_viewport_rect().size)
	set_position(Vector2.ZERO)


func change_vfs(new_vfs: VFS) -> void:
	vfs = new_vfs
	ide_vfs_changed.emit(new_vfs)
