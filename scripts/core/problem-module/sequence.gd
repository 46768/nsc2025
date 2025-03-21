class_name Sequence
extends RefCounted


var rom: Dictionary = {}
var cpu: SequenceCPU = SequenceCPU.new()
var program_source: String = ""


## Load data dictionary to ROM
func load_rom(rom_data: Dictionary) -> void:
	rom = rom_data.duplicate(true)

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
	program_source = source


## Step to next yield, running instructions between yields
func next() -> bool:
	var can_continue: bool = await cpu.run()
	return can_continue
