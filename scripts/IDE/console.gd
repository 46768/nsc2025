extends Control


var output_ratio = 0.8
var output_padding = 0.05
var input_ratio = 0.15

func setup_layout(console_size: Vector2) -> void:
	$ConsoleOutput.set_position(Vector2.ZERO)
	$ConsoleOutput.set_size(console_size * Vector2(1, output_ratio))
	
	$ConsoleOutputPanel.set_position(Vector2.ZERO)
	$ConsoleOutputPanel.set_size(console_size * Vector2(1, output_ratio+output_padding))
	
	$ConsoleInput.set_position(console_size * Vector2(0, output_ratio+output_padding))
	$ConsoleInput.set_size(console_size * Vector2(1, input_ratio))
