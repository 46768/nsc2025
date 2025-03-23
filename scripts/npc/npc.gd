extends StaticBody2D


@export var npc_data_resource: JSON = null
@export var npc_texture: Texture2D:
	set(texture):
		npc_texture = texture
		$Sprite2D.set_texture(texture)

@onready var interaction_text: Label = $Label

var npc_data: Dictionary
var interact_key: StringName

var text_shift: int = 192


func _ready() -> void:
	npc_data = npc_data_resource.data
	
	interact_key = StringName(npc_data.get("interactKey", "<null>"))
	
	interaction_text.set_text(npc_data.get("interactText", "<null>"))
	_on_screen_resize()
	
	Globals.screen_resized.connect(_on_screen_resize)
	SignalBus.on_main_initialized.connect(
			func()->void: interaction_text.reparent(Globals.player_ui))


func _on_screen_resize() -> void:
	# Center -> like 128 px down
	var screen_size: Vector2 = Globals.screen_size
	var screen_center: Vector2 = screen_size / 2
	
	@warning_ignore("integer_division")
	interaction_text.set_position(Vector2(0, screen_center.y+(text_shift/2)))
	interaction_text.set_size(Vector2(screen_size.x, 128)) # Set full screen wide


func _interact(get_keybind: bool, cleanup: bool) -> StringName:
	if get_keybind:
		# Put code for when adding interaction
		interaction_text.show()
		return interact_key
	
	if cleanup:
		# Put code for when removing interaction
		interaction_text.hide()
		return &""
	
	# Put code for interaction here
	print("NPC interacted")
	return &""
