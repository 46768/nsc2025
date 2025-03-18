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


func parse_operand(operand: String, rom: Dictionary) -> Variant:
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
		
		# Unknown or no modifier
		_:
			printerr("Unknown operand modifier '%s'" % operand[0])
			return ERR_HEX


func assemble(source: String, rom: Dictionary) -> Array[Array]:
	var lines: PackedStringArray = source.replace("\t", "").split("\n", false)
	var instructions: Array[Array]
		
	for i: int in range(len(lines)):
		var line: String = lines[i]
		var tokenized_line: Array = SequenceDSL.tokenize(line)
		
		if len(tokenized_line) == 1 and tokenized_line[0] == "":
			continue
		
		tokenized_line[0] = parse_opcode(tokenized_line[0])
		
		for j: int in range(1, len(tokenized_line)):
			var parsed_operand: Variant = SequenceDSL.parse_operand(
					tokenized_line[j], rom)
			
			if parsed_operand is int and parsed_operand == SequenceDSL.ERR_HEX:
				printerr("Parser hit an error at line %d" % i)
				return []
			else:
				tokenized_line[j] = parsed_operand
		
		instructions.append(tokenized_line)
	
	return instructions
