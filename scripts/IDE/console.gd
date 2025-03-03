extends Control


const OUTPUT_H_RATIO = 0.9
const INPUT_H_RATIO = 1 - OUTPUT_H_RATIO

func _ready() -> void:
	pass

func set_console_layout(console_size: Vector2) -> void:
	print("setting console inner")
	$ConsoleOutput.set_position(Vector2.ZERO)
	$ConsoleOutput.set_size(console_size * Vector2(1, OUTPUT_H_RATIO))
	
	$ConsoleInput.set_position(console_size * Vector2(0, OUTPUT_H_RATIO))
	$ConsoleInput.set_size(console_size * Vector2(1, INPUT_H_RATIO))
