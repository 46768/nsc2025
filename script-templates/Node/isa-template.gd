# meta-name: DSL ISA
# meta-description: A DSL instruction set architecture template

extends RefCounted

var isa_name: StringName = &""
var types: Dictionary[String, Callable] = {}
