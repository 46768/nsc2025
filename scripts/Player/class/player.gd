class_name Player
extends RefCounted


var interactions: Dictionary[String, Callable] = {}


func _init() -> void:
	pass


func process_interactions() -> void:
	for keybind: String in interactions.keys():
		if InputMap.has_action(keybind):
			if Input.is_action_just_pressed(keybind):
				interactions[keybind].call()
