class_name Sequence

var rom: Dictionary = {}
var cpu: SequenceCPU = SequenceCPU.new()

## Write data to ROM
func write_rom(label: String, value: Variant) -> void:
	rom[label] = value

## Erase data from ROM
func erase_rom(label: String) -> void:
	rom.erase(label)


## Load DSL source code into a CPU
func load_source(source: String) -> void:
	var program: Array[Array] = SequenceDSL.assemble(source, rom)
	cpu.load_program(program)


## Step to next yield, running instructions between yields
func next() -> bool:
	await cpu.run()
	return true
