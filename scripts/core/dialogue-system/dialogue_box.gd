extends MarginContainer


@onready var dialogue_texture_rect: TextureRect = (
		$PanelContainer/InnerMargin/Layout/CharacterTexture)
@onready var dialogue_message_box: RichTextLabel = (
		$PanelContainer/InnerMargin/Layout/Message)
@onready var inner_margin: MarginContainer = (
		$PanelContainer/InnerMargin)

var dialogue_texture: Texture2D = preload(
		"res://assets/textures/dialogue-system/nan.png")
var dialogue_message: String = ""
var dialogue_hash: String = ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Globals.screen_size)
	dialogue_texture_rect.texture = dialogue_texture
	dialogue_message_box.text = dialogue_message
	
	size.x = Globals.screen_size.x
	position.y = Globals.screen_size.y - size.y
	Globals.screen_resized.connect(_on_screen_resize)


func _on_screen_resize() -> void:
	size.x = Globals.screen_size.x
	position.y = Globals.screen_size.y - size.y


func cleanup() -> void:
	Globals.screen_resized.disconnect(_on_screen_resize)


func _on_button_pressed() -> void:
	Dialogue.delete_dialogue(dialogue_hash)
