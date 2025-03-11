extends Node
## Godot-Python binding provider
##
## A binding script to allows python script to be
## ran within Godot


# Python environment variables
const RESOURCE_PATH: String = "res://python-binding"
const DATA_PATH: String = "user://python-binding"
const ARCHIVE_FNAME: String = "python-packed.tar.gz"

var RES_PACKED_PATH: String
var USR_PACKED_PATH: String

var CONDA_PATH: String
var PYTHON3_BIN_PATH: String

var initialized: bool = false


## Run python script with given arguments in a blocking way
##
## Run a python script with given arguments in a blocking way
## and return the stdout+stderr as an array with the return code
## appended to it
func run_script(
	script_path: String, args: PackedStringArray
) -> Array:
	var src_path: String = Globals.gpathize(script_path)
	var bin_path: String = Globals.gpathize(PYTHON3_BIN_PATH)
	var cmd_arg: PackedStringArray = PackedStringArray([src_path])
	var output: Array = []
	
	cmd_arg.append_array(args)
	var ret_code = OS.execute(
		bin_path, cmd_arg,
		output, true
	)
	output.append(ret_code)
	
	return output


## Run python script with given arguments in a separate process
##
## Run a python script with given arguments in a separate process
## and return the pid of the process
func create_script_process(
	script_path: String, args: PackedStringArray
) -> int:
	var src_path: String = Globals.gpathize(script_path)
	var bin_path: String = Globals.gpathize(PYTHON3_BIN_PATH)
	var cmd_arg: PackedStringArray = PackedStringArray([src_path])
	
	cmd_arg.append_array(args)
	var pid = OS.create_process(
		bin_path, cmd_arg, false
	)
	
	return pid


# Unpack given conda .tar.gz archive into a directory
func __unpack_python_env(archive_path: String, dest_path: String) -> void:
	DirAccess.make_dir_absolute(dest_path)
	
	# Using tar
	OS.execute("tar", [
		"-xvzf", Globals.gpathize(archive_path),
		"-C", Globals.gpathize(dest_path),
	])


# Recursively delete a directory
func __clear_directory(dir_path: String, root_path: String):
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
		__clear_directory(directory.path_join(dir), root_directory)
	DirAccess.remove_absolute(directory)


# Runs on game startup (Specified this script as
# a global/singleton in project settings)
func _ready() -> void:
	RES_PACKED_PATH = Globals.join_paths(
			[RESOURCE_PATH, ARCHIVE_FNAME])
	USR_PACKED_PATH = Globals.join_paths([DATA_PATH, ARCHIVE_FNAME])

	CONDA_PATH = Globals.join_paths([DATA_PATH, "conda"])
	PYTHON3_BIN_PATH = {
		"Windows": Globals.join_paths([CONDA_PATH, "python.exe"]),
		"Linux": Globals.join_paths([CONDA_PATH, "bin", "python3"]),
	}[OS.get_name()]

	# Avoid repeated instantiation
	if initialized:
		return
	
	# Prepare python environment
	if not DirAccess.dir_exists_absolute(DATA_PATH):
		DirAccess.make_dir_absolute(DATA_PATH)
	
	# Copy packed env if not found
	if not (FileAccess.file_exists(RES_PACKED_PATH)
			or FileAccess.file_exists(USR_PACKED_PATH)):
		printerr("Cant find packed env file '%s'" % RES_PACKED_PATH)
		return
	if not FileAccess.file_exists(USR_PACKED_PATH):
		DirAccess.copy_absolute(RES_PACKED_PATH, USR_PACKED_PATH)
	
	# Unpack python environment
	if not DirAccess.dir_exists_absolute(CONDA_PATH):
		__unpack_python_env(USR_PACKED_PATH, CONDA_PATH)
	
	if not FileAccess.file_exists(PYTHON3_BIN_PATH):
		# Clear and unpack again
		__clear_directory(CONDA_PATH, CONDA_PATH)
		__unpack_python_env(USR_PACKED_PATH, CONDA_PATH)
	
	initialized = true
