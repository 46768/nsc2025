extends Node


const ERR_HEX: int = 0xDEADBEEFCAFE

# Base DSL mnemonics definitions
var BASE: Variant = preload(
		"res://scripts/core/problem-module/sequence-isa/base.gd").new()


func tokenize(line: String) -> PackedStringArray:
	# Get rid of comments -> strip extra spaces -> split into tokens
	return line.get_slice(";", 0).rstrip(" ").split("~")


func parse_opcode(opcode: String) -> PackedStringArray:
	var opcode_element: PackedStringArray = opcode.split("::")
	if len(opcode_element) == 1:
		opcode_element.append("BASE")
		opcode_element.reverse() # Put the namespace before the opcode
	
	return opcode_element


func parse_operand(
	operand: String,
	rom: Dictionary, 
	label_map: Dictionary[String, int],
	label_global: String,
	label_offset: int
) -> Variant:
	var operand_data: String = operand.right(-1)
	
	match operand[0]:
		# Data literals ($[t]. where [t] is type (no brackets))
		"$":
			var literal_type: String = operand_data.get_slice(".", 0)
			return BASE.types[literal_type].call(operand_data.right(-len(literal_type)-1))
		
		# Memory substitution
		"%":
			# Parse compile time substitution modifier (%)
			if operand[1] != ".":
				return rom[operand_data]
			
			# Skip runtime substitution modifier (%.)
			else:
				return operand
		
		# Label substitution
		">":
			if label_map.has(label_global+operand_data):
				return label_map[label_global+operand_data] - label_offset
			elif label_map.has(operand_data):
				return label_map[operand_data] - label_offset
			else:
				printerr("Unknow label '%s'" % operand_data)
				return ERR_HEX
		
		# Unknown or no modifier
		_:
			printerr("Unknown operand modifier '%s'" % operand[0])
			return ERR_HEX


func parse_label(lines: PackedStringArray) -> Dictionary[String, int]:
	var label_map: Dictionary[String, int] = {}
	var current_global: String = ""
	
	for i: int in range(len(lines)):
		var line: String = lines[i].lstrip(" \t").get_slice(";", 0)
		
		if not line.ends_with(":"):
			continue
		
		var label: String = line.left(-1)
		if label.begins_with("."):
			label = current_global + label
		else:
			current_global = label
		
		label_map[label] = i
	
	return label_map


func assemble(source: String, rom: Dictionary) -> Array[Array]:
	var lines: PackedStringArray = source.split("\n", false)
	var label_map: Dictionary[String, int] = parse_label(lines)
	var label_global: String = ""
	var label_offset: int = 0
	var instructions: Array[Array]
		
	for i: int in range(len(lines)):
		var line: String = lines[i].lstrip(" \t")
		
		# Empty lines
		if line == "":
			label_offset += 1
			continue
		
		var tokenized_line: Array = SequenceDSL.tokenize(line)
		
		# Global label
		if line.ends_with(":") and not line.begins_with("."):
			label_global = tokenized_line[0].left(-1)
			label_offset += 1
			continue
		# Comments
		elif len(tokenized_line) == 1 and tokenized_line[0] == "":
			label_offset += 1
			continue
		
		tokenized_line[0] = parse_opcode(tokenized_line[0])
		
		for j: int in range(1, len(tokenized_line)):
			var parsed_operand: Variant = SequenceDSL.parse_operand(
					tokenized_line[j], rom, label_map, label_global,
					label_offset)
			
			if parsed_operand is int and parsed_operand == SequenceDSL.ERR_HEX:
				printerr("Parser hit an error at line %d" % i)
				return []
			else:
				tokenized_line[j] = parsed_operand
		
		instructions.append(tokenized_line)
	
	return instructions
