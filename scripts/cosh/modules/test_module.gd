class_name COSHTestModule
extends COSHModule


func _init() -> void:
	module_name = "Test Module"
	commands = {
		"test-shell": test_shell
	}


func test_shell(_shell: COSH, _args: PackedStringArray) -> String:
	return "Hello!\n"
