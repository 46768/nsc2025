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
@onready var cont_size: Vector2 = get_size()

# TODO: Replace with modifiable icon data list
var icons_data: Array[DesktopIcon] = [
	DesktopIcon.new()
	.set_position(Vector2i(0, 0))
	.set_name("Code")
	.set_texture(preload("res://assets/textures/edit.svg")),
	DesktopIcon.new()
	.set_position(Vector2i(1, 0))
	.set_name("Quests")
	.set_texture(preload("res://assets/textures/tasklist.svg")),
]
var icon_size: int = IconSize.MEDIUM
var icon_margin: int = 16


func _ready() -> void:
	if use_solid_color_background:
		texture_bg.hide()
		
		solid_color_bg.show()
		solid_color_bg.set_color(solid_color_background)
	else:
		solid_color_bg.hide()
		
		texture_bg.show()
		texture_bg.set_texture(texture_background)
	
	_place_icons()
	
	resized.connect(_resize)


func _resize() -> void:
	cont_size = get_size()
	texture_bg.set_size(cont_size)
	solid_color_bg.set_size(cont_size)
	icons.set_size(cont_size)


func _place_icons() -> void:
	for icon: DesktopIcon in icons_data:
		var icon_tex: Texture2D = icon.get_texture()
		var icon_pos: Vector2i = icon.get_position()
		
		var icon_bitmap: BitMap = BitMap.new()
		icon_bitmap.create_from_image_alpha(icon_tex.get_image(), 0)
		
		var icon_node: TextureButton = TextureButton.new()
		icon_node.texture_normal = icon_tex
		icon_node.set_click_mask(icon_bitmap)
		icon_node.ignore_texture_size = true
		icon_node.stretch_mode = TextureButton.STRETCH_SCALE
		icon_node.set_size(Vector2(icon_size, icon_size))
		icon_node.set_position(Vector2(
				icon_pos.x*(icon_size+icon_margin)+icon_margin,
				icon_pos.y*(icon_size+icon_margin)+icon_margin))
		icon_node.set_z_index(1)
		icon_node.set_name("%s_%d_%d" % [
			icon.get_name(),icon_pos.x, icon_pos.y])
		icon_node.pressed.connect(icon.on_execute)
		
		icons.add_child(icon_node)
