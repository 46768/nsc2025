extends Node


func gpathize(path: String) -> String:
	return ProjectSettings.globalize_path(path)


func join_paths(paths: PackedStringArray) -> String:
	var path: String = ""
	for block in paths:
		path = path.path_join(block)
	return path


func wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout

func close_game() -> void:
	get_tree().quit()
