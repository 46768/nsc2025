extends BoxContainer


const FILE_TEXTURE: Texture2D = preload("res://assets/textures/file-tree/file.svg")
const DIR_TEXTURE: Texture2D = preload("res://assets/textures/file-tree/folder.svg")
const DIR_OPEN_TEXTURE: Texture2D = preload("res://assets/textures/file-tree/folder-opened.svg")


## A class for building a file tree from a VFS into a Tree node
class VFSTree:
	var attached_vfs: VFS
	var attached_tree: Tree
	
	func _init(vfs: VFS, tree: Tree) -> void:
		attached_vfs = vfs
		attached_tree = tree
		
		attached_vfs.data_changed.connect(build_tree)
	
	
	func change_vfs(new_vfs: VFS) -> void:
		attached_vfs.data_changed.disconnect(build_tree)
		attached_vfs = new_vfs
		attached_vfs.data_changed.connect(build_tree)
	
	
	func build_tree() -> void:
		attached_tree.clear()
		
		var item_dict: Dictionary = {}
		var bfs_queue: PackedStringArray = PackedStringArray(["/"])

		# Create root tree item
		item_dict["/"] = attached_tree.create_item()
		item_dict["/"].set_text(0, "/")
		item_dict["/"].set_icon(0, DIR_TEXTURE)
		
		while not bfs_queue.is_empty():
			# Pop path from queue
			var current_path: String = bfs_queue[0]
			bfs_queue.remove_at(0)

			var current_block: Dictionary = attached_vfs.get_block(current_path)
			var is_dir: bool = attached_vfs.is_dir(current_path)

			# Add sub-blocks to queue
			if is_dir:
				bfs_queue.append_array((current_block.content as Dictionary).keys())

			# Create tree item for current path
			if current_path != "/":
				var parent_item: TreeItem = item_dict[VFS.get_parent(current_path)]
				item_dict[current_path] = attached_tree.create_item(parent_item)
				item_dict[current_path].set_text(0, VFS.get_basename(current_path))
				if is_dir:
					item_dict[current_path].set_icon(0, DIR_TEXTURE)
				else:
					item_dict[current_path].set_icon(0, FILE_TEXTURE)


@onready var tree_view: Tree =  $FileTree
var vfstree: VFSTree
var ide_initialized: bool = false


func _on_ide_initialized(ide_vfs: VFS) -> void:
	vfstree = VFSTree.new(ide_vfs, tree_view)
	vfstree.build_tree()
	
	ide_initialized = true


func _on_ide_vfs_changed(new_vfs: VFS) -> void:
	vfstree.change_vfs(new_vfs)
	vfstree.build_tree()
