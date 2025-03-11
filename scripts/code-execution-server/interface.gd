extends Node


const SERVER_PORT: int = 56440
const SERVER_SCRIPT: String = "server.py"
const SERVER_KILL: String = "kill.py"
const SERVER_DIR: String = "code-execution"
const PY_RES_DIR: String = PythonBinding.RESOURCE_PATH
const PY_DATA_DIR: String = PythonBinding.DATA_PATH

var SERVER_SRC: String
var SERVER_DATA: String
var SERVER_CONFIG: String

var server_started: bool = false
var server_url: String = "http://localhost:%d" % SERVER_PORT
var server_pid: int
var server_socket: HTTPRequest


func _ready() -> void:
	SERVER_SRC = Globals.join_paths([SERVER_DIR, "src"])
	SERVER_DATA = Globals.join_paths([PY_DATA_DIR, SERVER_DIR, "data"])
	SERVER_CONFIG = Globals.join_paths([SERVER_DIR, "config"])

	var server_res: String = Globals.join_paths([PY_RES_DIR, SERVER_DIR])
	var server_dat: String = Globals.gpathize(Globals.join_paths([PY_DATA_DIR, SERVER_DIR]))
	
	# Check for resource availability
	if not DirAccess.dir_exists_absolute(server_res):
		printerr("Code execution resources does not exist on '%s'" % server_res)
		return
	
	# Copy resource to data
	if not DirAccess.dir_exists_absolute(server_dat):
		print("copying")
		Globals.copy_directory(server_res, server_dat)
		print("copied")
	
	__start_execution_server()
	await Globals.wait(2)
	
	server_socket = HTTPRequest.new()
	add_child(server_socket)
	server_socket.request_completed.connect(_on_server_responded)
	var pkt: Dictionary = Packet.format_packet_http(
			Packet.build_packet("rpx:ping", "pang!!"))
	server_socket.request("https://webhook.site/36e7b4a6-7821-432f-add5-eea0b721d502",
						  pkt["headers"],
						  HTTPClient.METHOD_POST,
						  pkt["body"])


func _on_server_responded(result: int,
						  response_code: int,
						  headers: PackedStringArray,
						  body: PackedByteArray) -> void:
	print(result)
	print(response_code)
	print(headers)
	print(body.get_string_from_utf8())


func _cleanup() -> void:
	print("closing server")
	server_socket.request(server_url,
						  ["Content-Type: application/json"],
						  HTTPClient.METHOD_POST,
						  JSON.stringify(Packet.build_packet(
								"rpx:end",
								"THY END IS NOW!!!")))
	OS.kill(server_pid)


func _exit_tree() -> void:
	_cleanup()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		_cleanup()


func __start_execution_server() -> void:
	var script_path: String = Globals.join_paths([
		PY_DATA_DIR, SERVER_SRC, SERVER_SCRIPT])
	var interpreter_path: String = Globals.gpathize(
			PythonBinding.PYTHON3_BIN_PATH)
	var ast_blacklist_path: String = Globals.join_paths([
		PY_DATA_DIR, SERVER_CONFIG, "ast-blacklist.yml"
	])
	if not DirAccess.dir_exists_absolute(SERVER_DATA):
		DirAccess.make_dir_absolute(SERVER_DATA)
	
	server_pid = PythonBinding.create_script_process(script_path, [
		str(SERVER_PORT), interpreter_path,
		Globals.gpathize(SERVER_DATA),
		Globals.gpathize(ast_blacklist_path),
	])
	print(server_pid)
