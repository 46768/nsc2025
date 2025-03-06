extends BoxContainer


const FILE_TEXTURE: Texture2D = preload("res://assets/textures/file-tree/file.svg")
const DIR_TEXTURE: Texture2D = preload("res://assets/textures/file-tree/folder.svg")
const DIR_OPEN_TEXTURE: Texture2D = preload("res://assets/textures/file-tree/folder-opened.svg")

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
		item_dict["/"].set_icon(0, DIR_TEXTURE)
		
		while not bfs_queue.is_empty():
			var current_path: String = bfs_queue[0]
			bfs_queue.remove_at(0)
			var current_block: Dictionary = attached_vfs.get_block(current_path)
			var is_dir: bool = attached_vfs.is_dir(current_path)
			if is_dir:
				bfs_queue.append_array((current_block.content as Dictionary).keys())
			if current_path != "/":
				var parent_item: TreeItem = item_dict[VFS.get_parent(current_path)]
				item_dict[current_path] = attached_tree.create_item(parent_item)
				item_dict[current_path].set_text(0, VFS.get_basename(current_path))
				if is_dir:
					item_dict[current_path].set_icon(0, DIR_TEXTURE)
				else:
					item_dict[current_path].set_icon(0, FILE_TEXTURE)


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
