extends Node


@export_range(49152, 65535) var server_port: int = 56440


# Python environment variables
const PYTHON_PACKED_PATH: String = "res://python-binding/python-packed.pypck"
const PYTHON_ENV_PATH: String = "user://python-env"

# Server variables
var server_thread: Thread
const SERVER_PATH: String = "res://python-binding/server.py"
var server_output = []

func _start_python_ws_server(server_path: String, port: int, python3_bin: String):
	var gpath = ProjectSettings.globalize_path(server_path)
	OS.execute(
		python3_bin, [gpath, "%d" % port],
		server_output, true
	)
	for i in server_output:
		print(i)

func _ready() -> void:
	# Prepare python environment
	var data_dir = DirAccess.open("user://")
	if not data_dir.dir_exists(PYTHON_ENV_PATH):
		data_dir.make_dir(PYTHON_ENV_PATH)
	
	# Copy packed env if not found
	var python_usr_packed_path: String = PYTHON_ENV_PATH + "/" + PYTHON_PACKED_PATH.get_file()
	if not FileAccess.file_exists(python_usr_packed_path):
		data_dir.copy(PYTHON_PACKED_PATH, python_usr_packed_path)
	
	if not data_dir.dir_exists(PYTHON_ENV_PATH + "/conda"):
		var unpacker: String
		var unpacker_src_f: String
		var unpacker_dest_f: String
		var unpack_output = []
		match OS.get_name():
			"Windows":
				unpacker = "Expand-Archive"
				unpacker_src_f = "-LiteralPath"
				unpacker_dest_f = "-DestinationPath"
			"Linux":
				unpacker = "tar"
				unpacker_src_f = "-xvzf"
				unpacker_dest_f = "-C"
		data_dir.make_dir(PYTHON_ENV_PATH + "/conda")
		var ret_code: int = OS.execute(unpacker, [
			unpacker_src_f,
			ProjectSettings.globalize_path(python_usr_packed_path),
			unpacker_dest_f,
			ProjectSettings.globalize_path(PYTHON_ENV_PATH + "/conda"),
			], unpack_output)
	
	# Start python server
	server_thread = Thread.new()
	server_thread.start(_start_python_ws_server.bind(
		SERVER_PATH, server_port, "python3"))
