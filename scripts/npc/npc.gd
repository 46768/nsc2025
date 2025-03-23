extends StaticBody2D


@export var npc_data_resource: JSON = null

var npc_data: Dictionary
var interact_key: StringName

var text_shift: int = 192
var interaction_text: Label = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	npc_data = npc_data_resource.data
	
	interact_key = StringName(npc_data.get("interactKey", "<null>"))
	
	interaction_text = Label.new()
	interaction_text.set_text(npc_data.get("interactText", "<null>"))
	interaction_text.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	interaction_text.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	_on_screen_resize()
	interaction_text.hide()
	
	Globals.screen_resized.connect(_on_screen_resize)
	SignalBus.on_main_initialized.connect(_on_main_initialized)


func _on_main_initialized() -> void:
	Globals.player_ui.add_child(interaction_text)


func _on_screen_resize() -> void:
	# Center -> like 128 px down
	var screen_size: Vector2 = Globals.screen_size
	var screen_center: Vector2 = screen_size / 2
	
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
