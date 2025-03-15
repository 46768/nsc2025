class_name COSHTestModule
extends COSHModule


func _init() -> void:
	module_name = "Test Module"
	commands = {
		"test-shell": test_shell,
		"resolve": resolve,
	}


func test_shell(_shell: COSH, _args: PackedStringArray) -> String:
	return "Hello!\n"


func resolve(_shell: COSH, args: PackedStringArray) -> String:
	if args.is_empty():
		return "resolve: missing path\n"
	
	return VFS.resolve_path(args[0])
