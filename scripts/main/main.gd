extends Node2D


var screen_size: Vector2


func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	$Ide.hide()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ToggleIDE"):
		$Ide.set_visible(not $Ide.is_visible())
