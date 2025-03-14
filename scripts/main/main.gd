extends Node2D


var screen_size: Vector2


func _ready() -> void:
	# Variable initializations
	screen_size = get_viewport_rect().size
	
	$Ide.hide()
	
	# Signal connections
	Globals.screen_resized.connect(_on_screen_resized)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ToggleIDE"):
		$Ide.set_visible(not $Ide.is_visible())


func _on_screen_resized() -> void:
	screen_size = get_viewport_rect().size
