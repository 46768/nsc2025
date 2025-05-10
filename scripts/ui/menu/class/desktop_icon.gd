class_name DesktopIcon
extends RefCounted


var position: Vector2i = Vector2i.ZERO
var name: String = "N/A"
var texture: Texture2D = preload("res://assets/textures/placeholder.jpg")
var on_execute: Callable = no_execute


static func from_application(app: Application) -> DesktopIcon:
	var desktop_icon: DesktopIcon = (DesktopIcon.new()
		.set_name(app.name)
		.set_texture(app.icon))
	return desktop_icon

func no_execute() -> void:
	print("%s clicked" % name)

func _init() -> void:
	pass


func set_name(new_name: String) -> DesktopIcon:
	name = new_name
	return self

func get_name() -> String:
	return name


func set_position(pos: Vector2i) -> DesktopIcon:
	position = pos
	return self

func get_position() -> Vector2i:
	return position


func set_texture(tex: Texture2D) -> DesktopIcon:
	texture = tex
	return self

func get_texture() -> Texture2D:
	return texture


func set_on_execute(fn: Callable) -> DesktopIcon:
	on_execute = fn
	return self

func get_on_execute() -> Callable:
	return on_execute

func execute() -> void:
	on_execute.call()
