class_name COSHPythonModule
extends COSHModule


func _init() -> void:
	module_name = "Python"
	commands = {
		"python3": request_execution,
		"python": request_execution,
	}
	signals = {}


func _format_traceback(traceback: String, fname: String, indent_cnt: int = 2) -> String:
	print(traceback)
	var traceback_lines: PackedStringArray = traceback.split("\n")
	
	# Removes AST parsing stack
	for __: int in range(5):
		traceback_lines.remove_at(1)
	
	traceback_lines[1] = traceback_lines[1].replace("\"<unknown>\"", "\"%s\"" % fname)
	
	print("\n".join(traceback_lines))
	return ("\t".repeat(indent_cnt)+"\n").join(traceback_lines)


func request_execution(shell: COSH, args: PackedStringArray) -> String:
	if args.is_empty():
		return "python3: missing file"
	var path: String = args[0]
	var abs_path: String = path if path.begins_with("/") else VFS.path_join(shell.cwd, path)
	abs_path = VFS.resolve_path(abs_path)
	
	if not shell.attached_vfs.block_exists(abs_path):
		return "python3: file not found"
	
	var code_result: Dictionary = await CodeServer.request_execution(
		shell.attached_vfs,
		abs_path
	)
	
	var ret_string: String = ""
	if "ast_failed" not in code_result:
		ret_string = code_result["stdout"] + code_result["stderr"]
	else:
		ret_string = "python3: bad file(s) detected, fix then run again\n\n"
		code_result.erase("ast_failed")
		for fpath: String in code_result.keys():
			var ferr: Dictionary = code_result[fpath]
			
			ret_string += "%s\n" % fpath
			for ername: String in ferr.keys():
				match ername:
					"syntax_err":
						ret_string += "\t%s:\n" % "Syntax Error"
						ret_string += "%s\n" % _format_traceback(ferr[ername], fpath)
					_:
						if not ferr[ername].is_empty():
							ret_string += "\tbanned %s:\n" % str(ername)
							for erval: String in ferr[ername]:
								ret_string += "\t\t%s\n" % str(erval)
			
	return ret_string
