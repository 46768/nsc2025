class_name COSHTempSignal
extends COSHModule


signal next_triggered
signal test_triggered


func _init() -> void:
	module_name = "TempSignal"
	commands = {
		"next": send_next_sig,
		"test": send_test_sig,
	}
	signals = {
		"next_sig": next_triggered,
		"test_sig": test_triggered,
	}


func send_next_sig(_shell: COSH, _args: PackedStringArray) -> String:
	next_triggered.emit()
	return ""


func send_test_sig(_shell: COSH, _args: PackedStringArray) -> String:
	test_triggered.emit()
	return "Code test result:\n\tExpected: Boat goes binted!!!\n\tReceived: Boat goes binted!!!\nAll test passed. Good Job!"
