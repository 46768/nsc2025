class_name ProblemClass
extends RefCounted


var name: String
var vfs: VFS
var sequence: Sequence = Sequence.new()


static func load_json(json: String) -> ProblemClass:
	var json_dict: Dictionary = JSON.parse_string(json)
	var problem_name: String = json_dict["name"]
	var vfs_class: VFS = VFS.new(json_dict["vfs"])
	var sequence_rom: Dictionary[String, Variant] = json_dict["sequence"]["rom"]
	var sequence_source: String = json_dict["sequence"]["source"]
	
	var problem: ProblemClass = ProblemClass.new(problem_name, vfs_class)
	problem.sequence.load_rom(sequence_rom)
	problem.sequence.load_source(sequence_source)
	
	return problem


func _init(iname: String, ivfs: VFS) -> void:
	name = iname
	vfs = ivfs


func start() -> void:
	sequence.next()


func prnt() -> void:
	print(name)
	print(vfs.data)
	print(sequence.rom)
	print(sequence.program_source)
