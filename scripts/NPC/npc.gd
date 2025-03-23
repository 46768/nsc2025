extends StaticBody2D


var text_shift: int = 192
var interaction_text: Label = Label.new()

var npc_problem: ProblemClass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_text = Label.new()
	interaction_text.set_text("press E to interact")
	interaction_text.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	interaction_text.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	_on_screen_resize()
	interaction_text.hide()
	
	npc_problem = Problem.create("NPCProblem", VFS.new())
	
	Globals.screen_resized.connect(_on_screen_resize)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


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
