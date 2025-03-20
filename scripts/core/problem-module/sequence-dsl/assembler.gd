extends Node
## An assembler for SeqASM
##
## Assembles source code as string to an intermediate code
## compatible with the CPU, supports label allowing for
## jumping to labels


## Error constant for assembler errors
const ERR_HEX: int = 0xDEADBEEFCAFE

## Base DSL type definitions
var BASE: Variant = preload(
		"res://scripts/core/problem-module/sequence-isa/base.gd").new()


## Tokenize a line to string tokens, stripping comments in the process
##
## Args:
##		line (str): A line containing the instruction
##
## Returns:
##		PackedStringArray: A string array containing the tokens in the line
func tokenize(line: String) -> PackedStringArray:
	# Get rid of comments -> strip extra spaces -> split into tokens
	return line.get_slice(";", 0).strip_edges().split("~")


## Parse an opcode into its namespace and mnemonic
##
## By default this function will use BASE namespace
##
## Args:
##		opcode (str): The raw opcode from tokenizing
##
## Returns:
##		PackedStringArray: A string array containing the namespace in the
##		first element, and the mnemonic in the second element
func parse_opcode(opcode: String) -> PackedStringArray:
	var opcode_element: PackedStringArray = opcode.split("::")
	if len(opcode_element) == 1:
		opcode_element.append("BASE")
		opcode_element.reverse() # Put the namespace before the opcode
	
	return opcode_element


## Parse operand for assemble time operand modifiers
##
## Parse an operand with its modifiers into a value
## in the intermediate code, valid modifiers include:[br]
##		[code]$[type].[/code]: data literals, replace [type] with the datatype of the data[br]
##		[code]%[/code]: assemble time memory substitution, use data from the rom[br]
##		[code]%.[/code]: runtime memory substitution, use data from the cpu's memory[br]
##		[code]>[/code]: label substitution, replaces with instruction index of the nearest downward instruction of the label[br]
## If no or invalid modifiers is used, [member ERR_HEX] will be returned
##
## Args:
##		operand (str): Operand token from tokenizing
##		rom (dict): A ROM containing data for assemble time substitution
##		label_map (dict[str, int]): A label table containing label as key, and line number as value
##		label_global (str): The current global label at time of parsing the operand
##		label_offset (int): The current line offset caused by empty lines, comments, or labels
##
## Returns:
##		any: Data from midifier parsing
func parse_operand(
	operand: String,
	rom: Dictionary, 
	label_map: Dictionary[String, int],
	label_global: String,
	label_offset: int
) -> Variant:
	var operand_data: String = operand.right(-1)
	
	match operand[0]:
		# Data literals ($[t]. where [t] is type (no brackets), t can be any length)
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


## Parse source code as string array into label table
##
## Args:
##		lines (PackedStringArray): String array of each lines in the source code
##
## Returns:
##		dict[str, int]: A label table containing the label as key, and line of label as value
func parse_label(lines: PackedStringArray) -> Dictionary[String, int]:
	var label_map: Dictionary[String, int] = {}
	var current_global: String = ""
	
	for i: int in range(len(lines)):
		# Strips tabs and space in the front -> remove comments -> remove extra spaces
		var line: String = lines[i].lstrip(" \t").get_slice(";", 0).rstrip(" \t")
		
		# Skips non label
		if not line.ends_with(":"):
			continue
		
		var label: String = line.left(-1)

		# Assumes label beginning with a . is a local label
		if label.begins_with("."):
			label = current_global + label
		else:
			current_global = label
		
		label_map[label] = i
	
	return label_map


## Assemble an intermediate code from a string source code and a ROM
##
## Uses a ROM for assemble time memory substitution in the source
## code, assembles to an intermdeiate code suitabel for running
## in the CPU. If during parsing the [member ERR_HEX] is returned
## the assembler will return an empty program that could be used
## in a CPU but will immediately halts
##
## Args:
##		source (str): Source code of the program as a single string
##		rom (dict): A table containing memory labels-data as key-value pairs
##
## Returns:
##		list[list]: The intermediate code of the program, if assembling fails, returns empty program
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
		if line.ends_with(":"):
			if not line.begins_with("."):
				label_global = tokenized_line[0].left(-1)
			label_offset += 1
			continue
		# Line comments
		elif len(tokenized_line) == 1 and tokenized_line[0] == "":
			label_offset += 1
			continue
		
		tokenized_line[0] = parse_opcode(tokenized_line[0])
		
		# Loops through each tokens, replace the tokens with parsed operand
		for j: int in range(1, len(tokenized_line)):
			var parsed_operand: Variant = SequenceDSL.parse_operand(
					tokenized_line[j], rom, label_map, label_global,
					label_offset)
			
			# Returns empty code if errors are found
			if parsed_operand is int and parsed_operand == SequenceDSL.ERR_HEX:
				printerr("Parser hit an error at line %d" % i)
				return []
			else:
				tokenized_line[j] = parsed_operand
		
		instructions.append(tokenized_line)
	
	return instructions
