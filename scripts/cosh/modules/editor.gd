class_name COSHEditor
extends COSHModule


signal cosh_editor_edit_sig(fpath: String, vfs: VFS)


func _init(buffer_mgr: BufferManager) -> void:
	module_name = "Editor"
	commands = {
		"code": cosh_editor_edit
	}
	signals = {
		"cosh_editor_edit": cosh_editor_edit_sig
	}
	
	cosh_editor_edit_sig.connect(buffer_mgr.open_buffer)


func cosh_editor_edit(shell: COSH, args: PackedStringArray) -> String:
	if args.is_empty():
		return "code: missing path\n"
	var path: String = args[0]
	var abs_path = path if path.begins_with("/") else VFS.path_join(shell.cwd, path)
	abs_path = VFS.resolve_path(abs_path)
	if not shell.attached_vfs.block_exists(abs_path):
		return "code: failed opening '%s': File not found\n" % path
	if shell.attached_vfs.is_dir(abs_path):
		return "code: failed opening '%s': Not a file\n" % path
	
	cosh_editor_edit_sig.emit(shell.attached_vfs, abs_path)
	
	return ""
