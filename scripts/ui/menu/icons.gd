extends Container


enum IconSize {
	SMALL=32,
	MEDIUM=64,
	LARGE=128
}

@export var use_solid_color_background: bool = true
@export var solid_color_background: Color = Color.DIM_GRAY
@export var texture_background: Texture2D

@onready var solid_color_bg: ColorRect = $SolidColorBG
@onready var texture_bg: TextureRect = $TextureBG
@onready var icons: Control = $Icons
@onready var apps: Control = $App
@onready var cont_size: Vector2 = get_size()

# TODO: Replace with modifiable icon data list
var icons_data: Array[DesktopIcon] = [
	DesktopIcon.from_application(
			Application.new(preload("res://scenes/ui/ide.tscn"))
			.set_name("IDE")
			.set_icon(preload("res://assets/textures/edit.svg"))),
	DesktopIcon.new()
	.set_position(Vector2i(1, 0))
	.set_name("Quests")
	.set_texture(preload("res://assets/textures/tasklist.svg")),
]
var icon_label_ratio: int = 4
var icon_size: int = ((icon_label_ratio+1)*IconSize.MEDIUM)/icon_label_ratio
var icon_margin: int = 16

var icon_refs: Dictionary[String, DesktopIcon] = {}
var icon_execution_hooks: Dictionary[String, bool] = {}


func _ready() -> void:
	if use_solid_color_background:
		texture_bg.hide()
		
		solid_color_bg.show()
		solid_color_bg.set_color(solid_color_background)
	else:
		solid_color_bg.hide()
		
		texture_bg.show()
		texture_bg.set_texture(texture_background)
	
	__place_icons()
	
	resized.connect(__resize)


func __resize() -> void:
	cont_size = get_size()
	texture_bg.set_size(cont_size)
	solid_color_bg.set_size(cont_size)
	icons.set_size(cont_size)
	apps.set_size(cont_size)


func _on_icon_pressed(icon_name: String) -> void:
	if not icon_execution_hooks.has(icon_name):
		icon_execution_hooks.set(icon_name, true)
		get_tree().create_timer(1).timeout.connect(__remove_icon_hook.bind(icon_name))
	else:
		icon_refs.get(icon_name).execute(apps)
		icon_execution_hooks.erase(icon_name)


func __remove_icon_hook(icon_name: String) -> void:
	icon_execution_hooks.erase(icon_name)


func __generate_icon_node(icon: DesktopIcon) -> Control:
	var icon_tex: Texture2D = icon.get_texture()
	var icon_pos: Vector2i = icon.get_position()
	
	var icon_bitmap: BitMap = BitMap.new()
	icon_bitmap.create_from_image_alpha(icon_tex.get_image(), -1)
	
	var icon_node: Control = Control.new()
	icon_node.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	icon_node.set_size(Vector2(icon_size, icon_size))
	icon_node.set_position(Vector2(
			icon_pos.x*(icon_size+icon_margin)+icon_margin,
			icon_pos.y*(icon_size+icon_margin)+icon_margin))
	icon_node.set_name("%s_%d_%d" % [
		icon.get_name(),icon_pos.x, icon_pos.y])
	
	var icon_button: TextureButton = TextureButton.new()
	icon_button.texture_normal = icon_tex
	icon_button.set_click_mask(icon_bitmap)
	icon_button.ignore_texture_size = true
	icon_button.stretch_mode = TextureButton.STRETCH_SCALE
	icon_button.set_size(Vector2(icon_size, icon_size))
	icon_button.pressed.connect(_on_icon_pressed.bind(icon_node.get_name()))
	
	var icon_label: Label = Label.new()
	icon_label.set_text(icon.get_name())
	icon_label.set_position(Vector2i(0, icon_size))
	icon_label.add_theme_font_size_override("font_size", icon_size/icon_label_ratio)
	icon_label.set_size(Vector2i(icon_size, icon_label.get_theme_font_size("font_size")))
	icon_label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	icon_label.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	
	icon_node.add_child(icon_label)
	icon_node.add_child(icon_button)
	
	return icon_node


func __place_icons() -> void:
	for icon: DesktopIcon in icons_data:
		var icon_node: Control = __generate_icon_node(icon)
		icon_refs.set(icon_node.get_name(), icon)
		icons.add_child(icon_node)
