extends BoxContainer


var tree_view: Tree
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tree_view = $FileTree
	var tree_root = tree_view.create_item()
	tree_root.set_text(0, "/")
	tree_root.set_text(1, "2/")
	
	for i in range(10):
		var tree_item = tree_view.create_item(tree_root)
		tree_item.set_text(0, "Hello %d" % i)
		tree_item.set_text(1, "1Hello %d" % i)
		for j in range(10):
			var tree_iitem = tree_view.create_item(tree_item)
			tree_iitem.set_text(0, "Helllo %d" % j)
