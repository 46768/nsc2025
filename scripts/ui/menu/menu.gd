extends MarginContainer


@export_range(0, 100) var outer_margin: int = 10
@export_range(0, 100) var inner_margin: int = 10

@onready var imarg: MarginContainer = $Panel/IMarg

func _ready() -> void:
	_resize()
	
	add_theme_constant_override("margin_bottom", outer_margin)
	add_theme_constant_override("margin_left", outer_margin)
	add_theme_constant_override("margin_top", outer_margin)
	add_theme_constant_override("margin_right", outer_margin)
	
	imarg.add_theme_constant_override("margin_bottom", inner_margin)
	imarg.add_theme_constant_override("margin_left", inner_margin)
	imarg.add_theme_constant_override("margin_top", inner_margin)
	imarg.add_theme_constant_override("margin_right", inner_margin)
	
	Globals.screen_resized.connect(_resize)


func _resize() -> void:
	set_size(Globals.screen_size)
	set_position(Vector2.ZERO)
