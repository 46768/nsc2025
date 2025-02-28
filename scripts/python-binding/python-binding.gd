extends Node


@export_range(49152, 65535) var server_port: int = 56440


# Python environment variables
var python_env_packed: String = "res://python-binding/python-packed.pypck"
var python_env_dirname: String = "user://python-env"

# Server variables
var server_thread: Thread
const SERVER_PATH: String = "res://python-binding/server.py"
var server_output = []

func _start_python_ws_server(server_path: String, port: int):
	var gpath = ProjectSettings.globalize_path(server_path)
	OS.execute(
		"python3", [gpath, "%d" % port],
		server_output, true
	)
	for i in server_output:
		print(i)

func _ready() -> void:
	# Prepare python environment
	
	# Start python server
	server_thread = Thread.new()
	server_thread.start(_start_python_ws_server.bind(
		SERVER_PATH, server_port))
