class_name ApplicationInstance
extends RefCounted


static var application_scene: PackedScene = preload(
		"res://scenes/ui/menu/application.tscn")

var application_ref: Application
var content_node: Node
var app_node: VBoxContainer


func _init(app_ref: Application) -> void:
	application_ref = app_ref
	content_node = application_ref.scene.instantiate()
	
	app_node = application_scene.instantiate()
	app_node.app_instance_ref = weakref(self)
	app_node.app_name = application_ref.name
	app_node.app_icon = application_ref.icon
	
	app_node.get_node("Content").add_child(content_node)


func get_app_node() -> VBoxContainer:
	return app_node
