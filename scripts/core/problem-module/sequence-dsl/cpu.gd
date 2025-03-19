class_name SequenceCPU
extends RefCounted
## A virtual CPU for running intermediate code
##
## A virtual CPU to process and run instructions from
## the [code]SequenceDSL[/code] assembler. The capability
## of the CPU is based on the loaded ISA, by default
## the CPU have a [code]BASE[/code] ISA for Turing completeness
## and basic output, and a [code]IDE[/code] ISA for IDE interactions


## Available instruction set architectures
var isa: Dictionary[String, Variant] = {
	"BASE": preload(
		"res://scripts/core/problem-module/sequence-isa/base.gd").new(),
	"IDE": preload(
		"res://scripts/core/problem-module/sequence-isa/ide.gd").new(),
}
var memory: Dictionary ## Memory for the CPU
var program: Array[Array] = [] ## Instructions of the currently loaded program
var instruction_ptr: int = 0 ## The instruction pointer of the program

## CPU flags
##
## 3rd: sign flag[br]
## 2nd: zero flag[br]
## 1st: halt flag[br]
## 0th: yield flag
var flags: int = 0b0000


## Internal; Performs pre-execution processing of the intermediate instruction
##
## Transform intermediate instruction into base ISA compatible operands.[br]
## A base ISA compatible operands contains an array containing the reference
## of the CPU executing the command, and the ram of the CPU in the given order,
## followed by operands. If an operand is a string and contains [code]%.[/code]
## at the start, a memory substitution will happens and replace the operand
## with the data at the memory label, if memory label doesn't exist then
## an error will occur
##
## Args:
##		instruction (Array): The instruction to process, includes the opcode
##
## Returns:
##		Array: A base ISA compatitle operands with processing applied
##
## Notes:
##		errors are not being handled intentionally as its easier to catch the
##		errors using the godot's debugger, and generally a program shouldn't
##		crash in production
func _process_operand(instruction: Array) -> Array:
	var operand: Array = [[self, memory]]
		
	for operand_token: Variant in instruction.slice(1):
		# Runtime substitution
		if operand_token is String and operand_token.begins_with("%."):
			operand.append(memory[operand_token.right(-2)])
		
		# No processing
		else:
			operand.append(operand_token)
	
	return operand


## Loads a program into the CPU
##
## Copies and load an assembled program into the
## CPU and reset the CPU state
##
## Args:
##		program_code (Array[Array]): The assembled to program to load into the CPU
func load_program(program_code: Array[Array]) -> void:
	program = program_code.duplicate(true)
	reset_program()


## Resets the CPU
##
## Sets the [member instruction_ptr] to 0, all flags to 0, and clears the ram
func reset_program() -> void:
	instruction_ptr = 0
	flags = 0b0000
	memory.clear()


## Runs the program until end of block/program
##
## Runs the loaded program until the yield flag, halt flag is on,
## or when there's no more instructions to execute. The yield flag
## will always be set to 0 on call, but not the halt flag.
##
## Returns:
##		bool: Whether or not the CPU can continue running without needing to reset
func run() -> bool:
	flags &= ~0b1  # Set yield flag to false
	
	while (instruction_ptr < len(program)  # Instruction pointer limiter
	and ~flags & 0b10  # Halt flag
	and ~flags & 0b01  # Yield flag
	):
		var instruction: Array = program[instruction_ptr]
		var opcode: PackedStringArray = instruction[0] # [0]: isa name, [1]: mnemonic
		var operand: Array = _process_operand(instruction)
		
		var isa_namespace: Object = isa[opcode[0]]
		await isa_namespace.call(opcode[1], operand)

		instruction_ptr += 1
	
	# Returns halt flag as bool
	return ((flags >> 1) & 0b1 == 0) and instruction_ptr < len(program)
