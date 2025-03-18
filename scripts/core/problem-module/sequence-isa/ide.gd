extends RefCounted

var isa_name: StringName = &"IDE"
var types: Dictionary[String, Callable] = {}


# ###############################
# Buffer Management
# ###############################

## Highlight a specific section of the current buffer
##
## Args:
##	[1] (int): Origin line
##	[2] (int): Origin column
##	[3] (int): Caret line
##	[4] (int): Caret column
func highlight_buffer(args: Array) -> void:
	var buffer_mgr: BufferManager = Globals.ide.buffer_mgr
	buffer_mgr.highlight_current_buffer.callv(args.slice(1))

## Clear the current buffer's highlight
func clear_highlight(_args: Array) -> void:
	var buffer_mgr: BufferManager = Globals.ide.buffer_mgr
	buffer_mgr.clear_current_buffer_highlight()


# ###############################
# Problem Statement
# ###############################

## Set the problem statement in the IDE
##
## Args:
##	[1]: (str): Text to set the statement to
func set_statement(args: Array) -> void:
	Globals.ide.problem_statement.set_text(args[1])
