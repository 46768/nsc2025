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
		
		for i: int in range(len(lines)):
			var line: String = lines[i]
			var tokenized_line: PackedStringArray = SequenceDSL.tokenize(line)
			
			for j: int in range(1, len(tokenized_line)):
				var parsed_operand: Variant = SequenceDSL.parse_operand(
						tokenized_line[j], ram)
				
				if parsed_operand is int and parsed_operand == SequenceDSL.ERR_HEX:
					printerr("Parser hit an error at line %d" % i)
					clear_instruction()
					return
				else:
					tokenized_line[j] = parsed_operand
			
			push_instruction(tokenized_line)
	
	
	func run() -> void:
		for operands: Array in instructions:
			var opcode: PackedStringArray = operands[0].split("::")
			var operand: Array = [ram]
			
			for operand_token: Variant in operands.slice(1):
				if operand_token is String and operand_token.begins_with("%."):
					operand.append(ram[operand_token.right(-2)])
				else:
					operand.append(operand_token)
			
			if len(opcode) == 1:
				if Sequence.BASE.has_method(opcode[0]):
					Sequence.BASE.callv(opcode[0], operand)
