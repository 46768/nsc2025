class_name Player
extends RefCounted


var sprite: Sprite2D
var camera: Camera2D

var available_interactions: Dictionary[Callable, StringName] = {}


func _init(isprite: Sprite2D, icamera: Camera2D) -> void:
	sprite = isprite
	camera = icamera


func add_interaction(keybind: StringName, callback: Callable) -> void:
	if not available_interactions.has(callback):
		available_interactions.set(callback, keybind)

func remove_interaction(callback: Callable) -> void:
	available_interactions.erase(callback)


func process_interactions() -> void:
	for callback: Callable in available_interactions.keys():
		var keybind: StringName = available_interactions.get(callback, &"")
		if (InputMap.has_action(keybind)
		and Input.is_action_just_pressed(keybind)):
			callback.call(false, false)
