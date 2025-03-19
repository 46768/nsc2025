class_name SequenceCPU
extends RefCounted


var isa: Dictionary[String, Variant] = {
	"BASE": preload(
		"res://scripts/core/problem-module/sequence-isa/base.gd").new(),
	"IDE": preload(
		"res://scripts/core/problem-module/sequence-isa/ide.gd").new(),
}
var ram: Dictionary
var program: Array[Array] = []
var instruction_ptr: int = 0

# CPU flags
	#	2nd: zero flag
	#	1st: halt flag
	#	0th: yield flag
var flags: int = 0b000


func _process_operand(instruction: Array) -> Array:
	var operand: Array = [[self, ram]]
		
	for operand_token: Variant in instruction.slice(1):
		# Runtime substitution
		if operand_token is String and operand_token.begins_with("%."):
			operand.append(ram[operand_token.right(-2)])
		
		# No processing
		else:
			operand.append(operand_token)
	
	return operand


func load_program(program_code: Array[Array]) -> void:
	program = program_code.duplicate(true)
	reset_program()


func reset_program() -> void:
	instruction_ptr = 0
	flags = 0b000
	ram.clear()


# Note: no data sanitization since its eaiser to catch errors using Godot than
# printerr
func run() -> bool:
	flags &= ~0b1  # Set yield flag to false
	
	while (instruction_ptr < len(program)  # Instruction pointer limiter
	and ~flags & 0b10  # Halt flag
	and ~flags & 0b01  # Yield flag
	):
		var instruction: Array = program[instruction_ptr]
		var opcode: PackedStringArray = instruction[0]
		var operand: Array = _process_operand(instruction)
		
		var isa_namespace: Object = isa[opcode[0]]
		await isa_namespace.call(opcode[1], operand)

		instruction_ptr += 1
	
	# Returns halt flag as bool
	return bool((flags >> 1) & 0b1)
