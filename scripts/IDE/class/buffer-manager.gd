class_name BufferManager
extends RefCounted
## A buffer management class for managing buffers
##
## A class for managing buffers for the IDE, allowing
## for multiple files to be opened using 1 IDE


const CLOSE_TEXTURE: Texture2D = preload("res://assets/textures/IDE/close.svg")

var tab_container: TabContainer # The tab container containing the buffers
var buffers: PackedStringArray = PackedStringArray([]) # Array containing the file path opened
var buffer_mapping: Dictionary[String, EditorManager] = {} # Mapping of file path to [EditorManager]


func _init(container: TabContainer) -> void:
	self.tab_container = container
	tab_container.tab_button_pressed.connect(close_buffer)


## Open a file editing buffer
##
## Args:
##		vfs (VFS): The VFS with the file data
##		fpath (str): The path to the file in the VFS
func open_buffer(vfs: VFS, fpath: String) -> void:
	var new_buffer_idx: int = tab_container.get_tab_count()
	var editor: CodeEdit = CodeEdit.new()
	var editor_mgr: EditorManager = EditorManager.new(editor)
	
	tab_container.add_child(editor)
	editor_mgr.load_vfs_file(fpath, vfs)
	vfs.buffer_reload.connect(editor_mgr.reload_data)
	
	buffers.append(fpath)
	buffer_mapping[fpath] = editor_mgr
	tab_container.set_tab_button_icon(new_buffer_idx, CLOSE_TEXTURE)
	tab_container.set_tab_title(new_buffer_idx, fpath)


## Close a buffer
##
## Args:
##		buffer_idx (int): The index of the buffer to close
func close_buffer(buffer_idx: int) -> void:
	var fpath: String = buffers[buffer_idx]
	var editor_mgr: EditorManager = buffer_mapping[fpath]

	editor_mgr.current_buffer["vfs"].buffer_reload.disconnect(editor_mgr.reload_data)
	editor_mgr.editor_ui.queue_free()
	
	buffer_mapping.erase(fpath)
	buffers.remove_at(buffer_idx)


## Highlights a section of the current buffer
##
## Uses CodeEdit.select under the hood
##
## Args:
##		start_line (int): Line of the start of selection
##		start_column (int): Column of the start of selection
##		caret_line (int): Line of the end of selection
##		caret_column (int): Column of the end of selection
func highlight_current_buffer(
		start_line: int,
		start_column: int, 
		caret_line: int, 
		caret_column: int) -> void:
	var editor: CodeEdit = buffer_mapping[buffers[tab_container.current_tab]].editor_ui
	editor.select(start_line, start_column, caret_line, caret_column)


## Clears selections of the current buffer
##
## Uses CodeEdit.deselect(0) under the hood
func clear_current_buffer_highlight() -> void:
	var editor: CodeEdit = buffer_mapping[buffers[tab_container.current_tab]].editor_ui
	editor.deselect(0)
