extends Control


# Called when the node enters the scene tree for the first time.
func setup_layout(container_size: Vector2) -> void:
	$ProblemStatement.set_position(Vector2.ZERO)
	$ProblemStatement.set_size(container_size)
