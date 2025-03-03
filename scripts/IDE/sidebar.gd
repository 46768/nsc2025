extends Container


const TAB_CONTAINER_H_RATIO = 0.1

# Called when the node enters the scene tree for the first time.
func setup_layout(sidebar_size: Vector2) -> void:
	$TabContainer.set_position(Vector2.ZERO)
	$TabContainer.set_size(sidebar_size * Vector2(1, TAB_CONTAINER_H_RATIO))
	
	$SidebarPanel.set_position(sidebar_size * Vector2(0, TAB_CONTAINER_H_RATIO))
	$SidebarPanel.set_size(sidebar_size * Vector2(1, 1-TAB_CONTAINER_H_RATIO))
	
	for node in $TabContainer.get_children():
		node.setup_layout(sidebar_size * Vector2(1, 1-TAB_CONTAINER_H_RATIO))
