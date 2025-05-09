extends TabContainer


signal buffer_tabs_initialized(buffer_mgr: BufferManager)

var buffer_manager: BufferManager


func _ready() -> void:
	buffer_manager = BufferManager.new(self)


func _on_ide_initialized(__: VFS) -> void:
	buffer_tabs_initialized.emit.call_deferred(buffer_manager)
