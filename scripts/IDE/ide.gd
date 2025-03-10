extends Control

@export_range(49152, 65535) var server_port: int = 56440


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Hello!")
	var res = PythonBinding.run("res://python-binding/server.py", [
		str(server_port),
		ProjectSettings.globalize_path(PythonBinding.PYTHON3_BIN_PATH),
	])
	print("Hello!".sha256_text())
	
	for i in res:
		print(i)
