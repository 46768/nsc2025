extends Node


@export_range(49152, 65535) var server_port: int = 56440


# Python environment variables
const PYTHON_PACKED_PATH: String = "res://python-binding/python-packed.pypck"
const PYTHON_ENV_PATH: String = "user://python-env"
var USR_PACKED_PATH: String = PYTHON_ENV_PATH+"/"+PYTHON_PACKED_PATH.get_file()
const PYTHON_CONDA_PATH: String = PYTHON_ENV_PATH + "/conda"
const PYTHON3_BIN_PATH: String = PYTHON_CONDA_PATH+"/bin/python3"

# Unpacking cmd table
const UNPACK_TABLE: Dictionary = {
	"Windows": ["Expand-Archive", "-LiteralPath", "-DestinationPath"],
	"Linux": ["tar", "-xvzf", "-C"],
}

# Server variables
var server_thread: Thread
const SERVER_PATH: String = "res://python-binding/server.py"
var server_output = []

func _start_python_ws_server(
	server_path: String, port: int, python3_bin: String
) -> void:
	var gpath = ProjectSettings.globalize_path(server_path)
	var bin_path = ProjectSettings.globalize_path(python3_bin)
	OS.execute(
		bin_path, [gpath, "%d" % port],
		server_output, true
	)
	for i in server_output:
		print(i)


func _unpack_python_env(pypck_path: String, dest_path: String) -> void:
	var unpacker: Array = UNPACK_TABLE[OS.get_name()]
	var unpack_output: Array = []
	OS.execute(unpacker[0], [
		unpacker[1], ProjectSettings.globalize_path(pypck_path),
		unpacker[2], ProjectSettings.globalize_path(dest_path),
	], unpack_output)
	pass

func _ready() -> void:
	# Prepare python environment
	var data_dir = DirAccess.open("user://")
	if not data_dir.dir_exists(PYTHON_ENV_PATH):
		data_dir.make_dir(PYTHON_ENV_PATH)
	
	# Copy packed env if not found
	if not FileAccess.file_exists(PYTHON_PACKED_PATH):
		printerr("Cant find packed env file '%s'" % PYTHON_PACKED_PATH)
		return
	if not FileAccess.file_exists(USR_PACKED_PATH):
		data_dir.copy(PYTHON_PACKED_PATH, USR_PACKED_PATH)
	
	if not data_dir.dir_exists(PYTHON_CONDA_PATH):
		data_dir.make_dir(PYTHON_CONDA_PATH)
		_unpack_python_env(USR_PACKED_PATH, PYTHON_CONDA_PATH)
	
	# Start python server
	server_thread = Thread.new()
	server_thread.start(_start_python_ws_server.bind(
		SERVER_PATH, server_port, PYTHON3_BIN_PATH))
