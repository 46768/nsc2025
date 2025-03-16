extends Node2D


@onready var test_texture: Texture2D = preload("res://icon.svg")

func _ready() -> void:
	# Variable initializations
	Globals.main = self
	
	$Ide.hide()
	
	Dialogue.spawn_dialogue("[wave]Test test hello world![/wave]", test_texture)
	await Globals.wait(1)
	Dialogue.clear_dialogue()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ToggleIDE"):
		$Ide.set_visible(not $Ide.is_visible())
