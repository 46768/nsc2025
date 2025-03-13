extends CodeEdit


signal editor_initialized(editor_mgr: EditorManager)

var editor_mgr: EditorManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	editor_mgr = EditorManager.new(self)


func _on_ide_initialized(__: VFS):
	editor_initialized.emit.call_deferred(editor_mgr)
