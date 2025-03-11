extends Node


const SERVER_PORT: int = 56440
const SERVER_SCRIPT: String = "server.py"
const SERVER_KILL: String = "kill.py"
const SERVER_DIR: String = "code-execution"
const PY_RES_DIR: String = PythonBinding.RESOURCE_PATH
const PY_DATA_DIR: String = PythonBinding.DATA_PATH

var SERVER_SRC: String = Globals.join_paths([SERVER_DIR, "src"])
var SERVER_DATA: String = Globals.join_paths([PY_DATA_DIR, SERVER_DIR, "data"])
var SERVER_CONFIG: String = Globals.join_paths([SERVER_DIR, "config"])

var server_started: bool = false
var server_url: String = "http://localhost:%d" % SERVER_PORT
var server_pid: int
var server_socket: HTTPRequest


func _ready() -> void:
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
	var pkt: Dictionary = Packet.build_packet("rpx:ping", {"msg": "pang"})
	send_pkt(pkt)


func _on_server_responded(result: int,
						  response_code: int,
						  headers: PackedStringArray,
						  body: PackedByteArray) -> void:
	print(result)
	print(response_code)
	print(headers)
	print(server_socket.get_body_size())
	print(body.get_string_from_utf8())


func _cleanup() -> void:
	__stop_execution_server()
	OS.kill(server_pid)


func _exit_tree() -> void:
	_cleanup()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		_cleanup()


func send_pkt(packet: Dictionary) -> void:
	var headers = PackedStringArray()
	for header in packet["headers"].keys():
		headers.append("%s: %s" % [header, packet["headers"][header]])
	server_socket.request(server_url,
						  headers,
						  HTTPClient.METHOD_POST,
						  packet["content"])


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


func __stop_execution_server() -> void:
	var script_path: String = Globals.join_paths([
		PY_DATA_DIR, SERVER_SRC, SERVER_KILL])
	
	PythonBinding.create_script_process(script_path,
										[str(SERVER_PORT)])
