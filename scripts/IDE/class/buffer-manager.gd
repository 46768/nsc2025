class_name BufferManager
extends  Object


const CLOSE_TEXTURE: Texture2D = preload("res://assets/textures/IDE/close.svg")

var tab_container: TabContainer
var buffers: PackedStringArray = PackedStringArray([])
var buffer_mapping: Dictionary[String, EditorManager] = {}


func _init(container: TabContainer) -> void:
	self.tab_container = container
	tab_container.tab_button_pressed.connect(close_buffer)


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


func close_buffer(buffer_idx: int) -> void:
	var fpath: String = buffers[buffer_idx]
	var editor_mgr: EditorManager = buffer_mapping[fpath]

	editor_mgr.current_buffer["vfs"].buffer_reload.disconnect(editor_mgr.reload_data)
	editor_mgr.editor_ui.queue_free()
	
	buffer_mapping.erase(fpath)
	buffers.remove_at(buffer_idx)


func highlight_current_buffer(
		start_line: int,
		start_column: int, 
		caret_line: int, 
		caret_column: int) -> void:
	var editor: CodeEdit = buffer_mapping[buffers[tab_container.current_tab]].editor_ui
	editor.select(start_line, start_column, caret_line, caret_column)


func clear_current_buffer_highlight() -> void:
	var editor: CodeEdit = buffer_mapping[buffers[tab_container.current_tab]].editor_ui
	editor.deselect(0)
	print("%d %d" % [editor.get_caret_line(), editor.get_caret_column()])
