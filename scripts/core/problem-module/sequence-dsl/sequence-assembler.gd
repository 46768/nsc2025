extends Node


const ERR_HEX: int = 0xDEADBEEFCAFE

# Base DSL mnemonics definitions
var BASE: Variant = preload(
		"res://scripts/core/problem-module/sequence-definition/base.gd").new()


func tokenize(line: String) -> PackedStringArray:
	# Get rid of comments -> strip extra spaces -> split into tokens
	return line.get_slice(";", 0).rstrip(" ").split("~")


func parse_operand(operand: String, ROM: Dictionary) -> Variant:
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
				return ROM[operand_data]
			
			# Skip runtime substitution modifier (%.)
			else:
				return operand
		
		# Unknown or no modifier
		_:
			printerr("Unknown operand modifier '%s'" % operand[0])
			return ERR_HEX
