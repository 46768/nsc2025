extends Control


## Emit once after the IDE is initialized
signal ide_initialized(ide_vfs: VFS)
## Emit when VFS changes
signal ide_vfs_changed(new_vfs: VFS)

@onready var sidebar_split: VSplitContainer = ($Panelc/Vsplit/SidebarSplit)
@onready var editor_split: VSplitContainer = ($Panelc/Vsplit/EditorSplit)
@onready var console: VBoxContainer = ($Panelc/Vsplit/EditorSplit/Console)
@onready var buffer_tabs: TabContainer = ($Panelc/Vsplit/EditorSplit/BufferTabs)

var vfs: VFS = null
var shell: COSH = null
var buffer_mgr: BufferManager = null
@onready var problem_statement: RichTextLabel = (
		$"Panelc/Imarg/Vsplit/SidebarSplit/Sidebar/Problem Viewer/Txt")


func _ready() -> void:
	_resize()
	
	vfs = VFS.new()
	vfs.set_name("ide_custom")
	
	Globals.screen_resized.connect(_resize)
	sidebar_split.dragged.connect(_sidebar_to_editor_sync)
	editor_split.dragged.connect(_editor_to_sidebar_sync)
	console.console_initialized.connect(_on_console_initialized)
	buffer_tabs.buffer_tabs_initialized.connect(_on_buffer_initialized)
	
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
	set_size(get_parent_control().get_size())
	$Panelc.set_size(get_size())
	set_position(Vector2.ZERO)


func change_vfs(new_vfs: VFS) -> void:
	vfs = new_vfs
	ide_vfs_changed.emit(new_vfs)
