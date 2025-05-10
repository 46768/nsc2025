class_name Application
extends Object


var name: String = "N/A"
var icon: Texture2D = preload("res://assets/textures/placeholder.jpg")
var scene: PackedScene


func _init(application_content: PackedScene) -> void:
	scene = application_content


func set_name(new_name: String) -> Application:
	name = new_name
	return self

func get_name() -> String:
	return name


func set_icon(new_icon: Texture2D) -> Application:
	icon = new_icon
	return self

func get_icon() -> Texture2D:
	return icon
