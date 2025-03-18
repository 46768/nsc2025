class_name SequenceCPU

static var BASE: Variant = preload(
		"res://scripts/core/problem-module/sequence-definition/base.gd").new()
var isa: Dictionary[String, Object] = {
	"BASE": BASE,
}
var ram: Dictionary
var program: Array[Array] = []
var instruction_ptr: int = 0

# CPU flags
	#	1st: halt flag
	#	0th: yield flag
var flags: int = 0b00


func _process_operand(instruction: Array) -> Array:
	var operand: Array = [[self, ram, flags]]
		
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
