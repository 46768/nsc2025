extends Node


signal received_packet

const SERVER_PORT: int = 56440
const SERVER_SCRIPT: String = "main.py"
const SERVER_KILL: String = "kill.py"
const SERVER_DIR: String = "code-execution"
const PY_RES_DIR: String = PythonBinding.RESOURCE_PATH
const PY_DATA_DIR: String = PythonBinding.DATA_PATH

var SERVER_SRC: String = DiskUtil.join_paths([SERVER_DIR, "src"])
var SERVER_DATA: String = DiskUtil.join_paths([PY_DATA_DIR, SERVER_DIR, "data"])
var SERVER_CONFIG: String = DiskUtil.join_paths([SERVER_DIR, "config"])

var server_started: bool = false
var server_url: String = "http://localhost:%d" % SERVER_PORT
var server_pid: int
var server_socket: HTTPRequest
var server_requesting: bool = false
var server_response: Dictionary


func _ready() -> void:
	var server_res: String = DiskUtil.join_paths([PY_RES_DIR, SERVER_DIR])
	var server_dat: String = DiskUtil.gpathize(
			DiskUtil.join_paths([PY_DATA_DIR, SERVER_DIR]))
	
	# Check for resource availability
	if not DirAccess.dir_exists_absolute(server_res):
		printerr("Code execution resources does not exist on '%s'" % server_res)
		return
	
	# Copy resource to data
	if not DirAccess.dir_exists_absolute(server_dat):
		print("copying")
		DiskUtil.copy_directory(server_res, server_dat)
		print("copied")
	
	__start_execution_server()
	await Globals.wait(2)
	
	server_socket = HTTPRequest.new()
	add_child(server_socket)
	server_socket.request_completed.connect(_on_server_responded)
	server_socket.set_accept_gzip(false)
	var pkt: Dictionary = Packet.build_packet("/net", "ping:pong", 000,
			{"msg": "pang"})
	await send_pkt(pkt)


func _on_server_responded(_result: int,
						  response_code: int,
						  headers: PackedStringArray,
						  body: PackedByteArray) -> void:
	server_response = Packet.decode_packet(
			"/", response_code, headers, body.get_string_from_utf8())
	received_packet.emit()
	server_requesting = false


func _get_response() -> Dictionary:
	await received_packet
	return server_response


func _cleanup() -> void:
	__stop_execution_server()
	#OS.kill(server_pid)


func _exit_tree() -> void:
	_cleanup()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		_cleanup()


func send_pkt(packet: Dictionary) -> void:
	if server_requesting:
		await received_packet
	var headers: PackedStringArray = PackedStringArray()
	for header in packet["headers"].keys():
		headers.append("%s: %s" % [header, packet["headers"][header]])
	var _err = server_socket.request(
			server_url + packet["url"],
			headers,
			HTTPClient.METHOD_POST,
			packet["content"])
	server_requesting = true


func request_execution(vfs: VFS, entry_point: String) -> PackedStringArray:
	var request_packet: Dictionary = Packet.build_packet(
		"/execution", "request", 000, {
			"vfs": vfs.data,
			"entryPoint": entry_point})
	await send_pkt(request_packet)
	var packet: Dictionary = await _get_response()
	var response: Dictionary = JSON.parse_string(packet["content"])
	return PackedStringArray([response["stdout"], response["stderr"]])


func __start_execution_server() -> void:
	var script_path: String = DiskUtil.join_paths([
		PY_DATA_DIR, SERVER_SRC, SERVER_SCRIPT])
	var interpreter_path: String = DiskUtil.gpathize(
			PythonBinding.PYTHON3_BIN_PATH)
	var ast_blacklist_path: String = DiskUtil.join_paths([
		PY_DATA_DIR, SERVER_CONFIG, "ast-blacklist.yml"
	])
	if not DirAccess.dir_exists_absolute(SERVER_DATA):
		DirAccess.make_dir_absolute(SERVER_DATA)
	
	server_pid = PythonBinding.create_script_process(script_path, [
		str(SERVER_PORT), interpreter_path,
		DiskUtil.gpathize(SERVER_DATA),
		DiskUtil.gpathize(ast_blacklist_path),
	])


func __stop_execution_server() -> void:
	var script_path: String = DiskUtil.join_paths([
		PY_DATA_DIR, SERVER_SRC, SERVER_KILL])
	
	PythonBinding.create_script_process(script_path,
										[str(SERVER_PORT)])
