extends Node


signal screen_resized

@onready var screen_size: Vector2 = get_tree().get_root().size

var main: Node2D = null
var ide: Control = null
var player: Player = null
var player_ui: CanvasLayer = null


func _ready() -> void:
	get_tree().get_root().size_changed.connect(_on_screen_resized)


func _on_screen_resized() -> void:
	screen_size = get_tree().get_root().size
	screen_resized.emit()


func wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout


func close_game() -> void:
	CodeServer._cleanup()
	get_tree().quit()
