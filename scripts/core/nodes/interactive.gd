class_name Interactive
extends Area2D


@export var interaction_path: String

var text_shift: int = 192
var interaction_text: Label

var npc_problem: ProblemClass


func _ready() -> void:
	print("json text")
	var file: FileAccess = FileAccess.open(interaction_path, FileAccess.READ)
	print(JSON.parse_string(file.get_as_text()))
	
	interaction_text = Label.new()
	interaction_text.set_text("press E to interact")
	interaction_text.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	interaction_text.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	_on_screen_resize()
	interaction_text.hide()
	
	npc_problem = Problem.create("NPCProblem", VFS.new())
	
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
		return &"KeyE"
	
	if cleanup:
		# Put code for when removing interaction
		interaction_text.hide()
		return &""
	
	# Put code for interaction here
	print("NPC interacted")
	return &""
