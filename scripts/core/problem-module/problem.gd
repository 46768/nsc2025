class_name ProblemClass


var name: String = ":No Name"
var vfs: VFS = VFS.new()
var sequence_idx: int = 0


func _init(iname: String, ivfs: VFS) -> void:
	name = iname
	vfs = ivfs


func next_sequence() -> void:
	sequence_idx += 1
