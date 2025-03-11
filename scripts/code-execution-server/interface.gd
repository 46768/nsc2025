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
var server_thread: Thread
var server_pid: int
var server_socket: WebSocketPeer


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
		__copy_directory(server_res, server_dat)
		print("copied")
	
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
	#server_thread = Thread.new()
	#server_thread.start(__start_execution_server)
	
	server_socket = WebSocketPeer.new()
	var err := server_socket.connect_to_url("ws://localhost:%d" % SERVER_PORT,
								TLSOptions.client_unsafe())
	print(server_socket.get_ready_state())
	if err != OK:
		printerr("Failed to get connection to server")
		set_process(false)
	else:
		await Globals.wait(10)
		server_socket.send_text(
				JSON.stringify(Packet.build_packet("rpx:ping", "")))
		server_started = true


func _process(_delta: float) -> void:
	server_socket.poll()
	var state = server_socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while server_socket.get_available_packet_count():
			print(server_socket.get_packet().get_string_from_ascii())
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		set_process(false)


func _exit_tree() -> void:
	print("closing game")
	server_socket.send_text(
			JSON.stringify(Packet.build_packet("rpx:end", "")))
	OS.kill(server_pid)
	await Globals.wait(4)
	server_socket.close()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		print("closing game")
		server_socket.send_text(
				JSON.stringify(Packet.build_packet("rpx:end", "")))
		await Globals.wait(4)
		server_socket.close()


func __copy_directory(from: String, to: String) -> void:
	DirAccess.make_dir_recursive_absolute(to)
	var src: String = from
	var dst: String = to
	if not src.ends_with("/"):
		src += "/"
	if not dst.ends_with("/"):
		dst += "/"
	
	var source_dir = DirAccess.open(src);
	
	for filename in source_dir.get_files():
		source_dir.copy(src + filename, dst + filename)
		
	for dir in source_dir.get_directories():
		__copy_directory(src + dir + "/", dst + dir + "/")


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
	
	var out = PythonBinding.run_script(script_path, [
		str(SERVER_PORT), interpreter_path,
		Globals.gpathize(SERVER_DATA),
		Globals.gpathize(ast_blacklist_path),
	])
	print(out)
	server_started = false
