extends Node


var IDE: Control = null


func gpathize(path: String) -> String:
	return ProjectSettings.globalize_path(path)


func join_paths(paths: PackedStringArray) -> String:
	var path: String = ""
	for block in paths:
		path = path.path_join(block)
	return path


# Recursively delete a directory
func delete_directory(dir_path: String, root_path: String):
	var directory: String = ProjectSettings.globalize_path(dir_path)
	var root_directory: String = ProjectSettings.globalize_path(root_path)
	var sliced_dir: PackedStringArray = directory.split("/")
	# Prevent deleting ancestor root
	if (len(directory) < len(root_directory)
	or not directory.begins_with(root_directory)): 
		return
	
	# Prevent using . and .. to indirectly reference root directory
	if ".." in sliced_dir:
		return
	
	for file in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(file))
	for dir in DirAccess.get_directories_at(directory):
		delete_directory(directory.path_join(dir), root_directory)
	DirAccess.remove_absolute(directory)


func copy_directory(from: String, to: String) -> void:
	DirAccess.make_dir_recursive_absolute(to)
	var src: String = from
	var dst: String = to
	if not src.ends_with("/"):
		src += "/"
	if not dst.ends_with("/"):
		dst += "/"
	
	var source_dir = DirAccess.open(src);
	
	for filename in source_dir.get_files():
		source_dir.copy(src + filename, dst + filename)
		
	for dir in source_dir.get_directories():
		copy_directory(src + dir + "/", dst + dir + "/")


func wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout


func close_game() -> void:
	CodeServer._cleanup()
	get_tree().quit()
