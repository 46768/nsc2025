extends Node


@onready var screen_resized: Signal = get_tree().get_root().size_changed
@onready var screen_size: Vector2 = get_tree().get_root().size

var main: Node2D = null
var ide: Control = null
var player: Player = null
var player_ui: CanvasLayer = null


func _ready() -> void:
	screen_resized.connect(_on_screen_resized)


func _on_screen_resized() -> void:
	screen_size = get_tree().get_root().size


func wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout


func close_game() -> void:
	CodeServer._cleanup()
	get_tree().quit()
