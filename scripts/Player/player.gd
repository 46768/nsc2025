extends CharacterBody2D


@export var speed: float = 300.0
@export var jump_velocity: float = 400.0

@onready var sprite: Sprite2D = $Sprite
@onready var camera: Camera2D = $Camera

var player: Player


func _ready() -> void:
	player = Player.new(sprite, camera)
	Globals.player = player


func _process(_delta: float) -> void:
	player.process_interactions()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("KeySpace") and is_on_floor():
		velocity.y = -jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: float = Input.get_axis("KeyA", "KeyD")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
