extends BoxContainer

class VFSTree:
	var attached_vfs: VFS
	var attached_tree: Tree
	
	func _init(vfs: VFS, tree: Tree) -> void:
		attached_vfs = vfs
		attached_tree = tree
	
	
	func build_tree() -> void:
		attached_tree.clear()
		
		var item_dict: Dictionary = {}
		var bfs_queue: PackedStringArray = PackedStringArray(["/"])
		item_dict["/"] = attached_tree.create_item()
		item_dict["/"].set_text(0, "/")
		
		while not bfs_queue.is_empty():
			var current_path: String = bfs_queue[0]
			bfs_queue.remove_at(0)
			var current_block: Dictionary = attached_vfs.get_block(current_path)
			if (current_block.type as VFS.FileType) == VFS.FileType.DIRECTORY:
				bfs_queue.append_array((current_block.content as Dictionary).keys())
			if current_path != "/":
				var parent_item: TreeItem = item_dict[VFS.get_parent(current_path)]
				item_dict[current_path] = attached_tree.create_item(parent_item)
				item_dict[current_path].set_text(0, VFS.get_basename(current_path))


var tree_view: Tree
var vfstree: VFSTree
var ide_initialized: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tree_view = $FileTree


func _on_ide_initialized(ide_vfs: VFS) -> void:
	vfstree = VFSTree.new(ide_vfs, tree_view)
	vfstree.build_tree()
	
	ide_vfs.data_changed.connect(_on_vfs_modified)
	ide_initialized = true


func _on_vfs_modified() -> void:
	vfstree.build_tree()
