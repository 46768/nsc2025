extends Node2D


@onready var interaction_area: Area2D = $InteractionArea
var text_shift: int = 512
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
	Globals.main.add_child(interaction_text)


func _on_screen_resize() -> void:
	# Center -> like 128 px down
	var screen_size: Vector2 = Globals.screen_size
	var screen_center: Vector2 = screen_size / 2
	
	interaction_text.set_position(Vector2(0, screen_center.y-(text_shift/2)))
	interaction_text.set_size(Vector2(screen_size.x, text_shift)) # Set full screen wide


func _on_interaction_area_body_entered(body: Node2D) -> void:
	print("%s entered interaction area" % body.name)
	if "player" in body:
		if interaction_text != null:
			interaction_text.show()
		body.player.interactions["KeyE"] = _on_npc_interacted
		print("Node got player property in it")


func _on_interaction_area_body_exited(body: Node2D) -> void:
	print("%s exited interaction area" % body.name)
	if "player" in body:
		if interaction_text != null:
			interaction_text.hide()
		body.player.interactions.erase("KeyE")
		print("Node got player property in it")


func _on_npc_interacted() -> void:
	print("NPC interacted")
