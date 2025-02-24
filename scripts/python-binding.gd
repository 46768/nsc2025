extends Node


var thread: Thread
var server_output = []

func _start_python_ws_server(port: int):
	print("Started python websocket server on port ", port)
	var server_path: String = ProjectSettings.globalize_path(
		"res://python-binding/server.py"
	)
	OS.execute("python3", [server_path], server_output,
	true)
	for i in server_output:
		print(i)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thread = Thread.new()
	thread.start(_start_python_ws_server.bind(12345))

func _exit_tree() -> void:
	thread.wait_to_finish()
	for i in server_output:
		print(i)
