extends Node


var loaded_problem: Dictionary[String, ProblemClass] = {}


func create(problem_name: String, vfs: VFS) -> ProblemClass:
	var problem: ProblemClass = ProblemClass.new(problem_name, vfs)
	loaded_problem[problem_name] = problem
	return problem

func load_from_string(json: String) -> ProblemClass:
	var json_dict: Dictionary = JSON.parse_string(json)
	var problem_name: String = json_dict["name"]
	var vfs_class: VFS = VFS.new(json_dict["vfs"])
	var sequence_rom: Dictionary[String, Variant] = json_dict["sequence"]["rom"]
	var sequence_source: String = json_dict["sequence"]["source"]
	
	var problem: ProblemClass = create(problem_name, vfs_class)
	problem.sequence.load_rom(sequence_rom)
	problem.sequence.load_source(sequence_source)
	
	return problem

func load_from_path(path: String) -> ProblemClass:
	var data_file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var data: String = data_file.get_as_text(true)
	
	return load_from_string(data)


func unload_problem(problem_name: String) -> void:
	loaded_problem.erase(problem_name)


func start_problem(problem_name: String) -> void:
	loaded_problem[problem_name].sequence.cpu.reset_program()
	loaded_problem[problem_name].sequence.next()
