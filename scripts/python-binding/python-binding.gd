extends Node


# Python environment variables
const PYTHON_PACKED_PATH: String = "res://python-binding/python-packed.tar.gz"
const PYTHON_ENV_PATH: String = "user://python-env"
var USR_PACKED_PATH: String = PYTHON_ENV_PATH+"/"+PYTHON_PACKED_PATH.get_file()
const PYTHON_CONDA_PATH: String = PYTHON_ENV_PATH + "/conda"
var PYTHON3_BIN_PATH: String = {
	"Windows": PYTHON_CONDA_PATH+"/python.exe",
	"Linux": PYTHON_CONDA_PATH+"/bin/python3",
}[OS.get_name()]
var instantiated: bool = false


func python_run(
	script_path: String, args: PackedStringArray
) -> Array:
	var gpath = ProjectSettings.globalize_path(script_path)
	var bin_path = ProjectSettings.globalize_path(PYTHON3_BIN_PATH)
	var cmd_arg = PackedStringArray([gpath])
	var output = []
	cmd_arg.append_array(args)
	var ret_code = OS.execute(
		bin_path, cmd_arg,
		output, true
	)
	output.append(ret_code)
	
	return output


func _unpack_python_env(pypck_path: String, dest_path: String) -> void:
	var unpack_output: Array = []
	# Using tar
	OS.execute("tar", [
		"-xvzf", ProjectSettings.globalize_path(pypck_path),
		"-C", ProjectSettings.globalize_path(dest_path),
	], unpack_output)


func _clear_directory(dir_path: String, root_path: String):
	var directory = ProjectSettings.globalize_path(dir_path)
	var root_directory = ProjectSettings.globalize_path(root_path)
	var sliced_dir = directory.split("/")
	# Prevent deleting ancestor root
	if len(directory) < len(root_directory) or not directory.begins_with(root_directory): 
		return
	# Prevent using . and .. to indirectly reference root directory
	if "." in sliced_dir or ".." in sliced_dir:
		return
	for file in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(file))
	for dir in DirAccess.get_directories_at(directory):
		_clear_directory(directory.path_join(dir), root_directory)
	DirAccess.remove_absolute(directory)


func _ready() -> void:
	# Avoid repeated instantiation
	if instantiated:
		return
	# Prepare python environment
	var data_dir = DirAccess.open("user://")
	if not data_dir.dir_exists(PYTHON_ENV_PATH):
		data_dir.make_dir(PYTHON_ENV_PATH)
	
	# Copy packed env if not found
	if not FileAccess.file_exists(PYTHON_PACKED_PATH) and not FileAccess.file_exists(USR_PACKED_PATH):
		printerr("Cant find packed env file '%s'" % PYTHON_PACKED_PATH)
		return
	if not FileAccess.file_exists(USR_PACKED_PATH):
		data_dir.copy(PYTHON_PACKED_PATH, USR_PACKED_PATH)
	
	# Unpack python environment
	if not data_dir.dir_exists(PYTHON_CONDA_PATH):
		data_dir.make_dir(PYTHON_CONDA_PATH)
		_unpack_python_env(USR_PACKED_PATH, PYTHON_CONDA_PATH)
	
	if not FileAccess.file_exists(PYTHON3_BIN_PATH):
		# Clear and unpack again
		_clear_directory(PYTHON_CONDA_PATH, PYTHON_CONDA_PATH)
		data_dir.make_dir(PYTHON_CONDA_PATH)
		_unpack_python_env(USR_PACKED_PATH, PYTHON_CONDA_PATH)
	
	instantiated = true
