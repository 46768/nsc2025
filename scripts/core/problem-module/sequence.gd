class_name Sequence


static var BASE: Variant = preload(
		"res://scripts/core/problem-module/sequence-definition/base.gd").new()

var sequence: Array[SequenceGroup] = []
var sequence_idx: int = 0

var ram: Dictionary = {}


func _init() -> void:
	pass


func new_group() -> SequenceGroup:
	var group: SequenceGroup = SequenceGroup.new(ram)
	sequence.append(group)
	
	return group


func next() -> void:
	if sequence_idx >= len(sequence):
		return
	sequence[sequence_idx].run()
	sequence_idx += 1


class SequenceGroup:
	static var type_map: Dictionary[String, Callable] = {
		"s": str,
		"m": func(x:String)->String: return "!??"+str(x),
		"d": func(x:String)->int: return int(x),
	}
	
	var instructions: Array[Array] = []
	var ram: Dictionary
	
	func _init(iram: Dictionary) -> void:
		ram = iram
	
	
	func push_instruction(operands: Array) -> void:
		instructions.append(operands)
	
	
	func clear_instruction() -> void:
		instructions.clear()
	
	
	func parse_source(source: String) -> void:
		clear_instruction()
		var lines: PackedStringArray = source.replace("\t", "").split("\n", false)
		
		for j: int in range(len(lines)):
			var line: String = lines[j]
			var raw_opcode: PackedStringArray = line.split("~")
			var formatted_opcode: Array = raw_opcode.duplicate()
			
			for i: int in range(1, len(raw_opcode)):
				var opcode: String = raw_opcode[i].get_slice(";", 0).rstrip(" ")
				var raw_data: String = opcode.right(-1)
				if opcode.begins_with("$"):
					var opcode_type: String = opcode.get_slice(".", 0).right(-1)
					var _opcode_type_namespace: String = opcode_type.get_slice("::", 0)
					opcode_type = opcode_type.get_slice("::", 1)
					if not type_map.has(opcode_type):
						printerr("Error parsing line %d: invalid literal type '%s'" % [j, opcode_type])
						clear_instruction()
						return
					
					if not opcode.contains("::"):
						formatted_opcode[i] = Sequence.BASE.types[opcode_type].call(raw_data.right(-2))
				elif opcode.begins_with("%"):
					if opcode[1] != ".":
						formatted_opcode[i] = ram[raw_data]
			
			push_instruction(formatted_opcode)
	
	
	func run() -> void:
		for operands: Array in instructions:
			var opcode: PackedStringArray = operands[0].split("::")
			var operand: Array = [ram]
			
			for oprand: Variant in operands.slice(1):
				if oprand is String and oprand.begins_with("%."):
					operand.append(ram[oprand.right(-2)])
				else:
					operand.append(oprand)
			
			if len(opcode) == 1:
				if Sequence.BASE.has_method(opcode[0]):
					Sequence.BASE.callv(opcode[0], operand)
