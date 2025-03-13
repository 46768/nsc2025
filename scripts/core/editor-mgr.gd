class_name EditorManager
extends Object


var editor_ui: CodeEdit
var highlighter_data: Dictionary; var synt_highlighter: CodeHighlighter
var symbols_lut: Dictionary
var current_buffer: Dictionary

func _init(edit_ui: CodeEdit) -> void:
	editor_ui = edit_ui
	
	load_colors("res://assets/json/IDE/syntax-highlighting/default.json")
	parse_symbol_lut("res://assets/json/IDE/symbol_lut.json")
	
	editor_ui.code_completion_requested.connect(handle_autocomplete)
	editor_ui.text_changed.connect(handle_autocomplete)
	editor_ui.text_changed.connect(save_buffer)


func load_colors(json_path: String) -> void:
	var json_file = FileAccess.open(json_path, FileAccess.READ)
	var colors = JSON.parse_string(json_file.get_as_text())
	highlighter_data = colors
	
	var highlighter = CodeHighlighter.new()
	highlighter.number_color = colors["number"]
	highlighter.symbol_color = colors["symbol"]
	highlighter.function_color = colors["function"]
	
	for str_token in colors["string"]["token"]:
		highlighter.add_color_region(
			str_token, str_token, 
			colors["string"]["color"], false
		)
	
	# Python keywords
	for keyword in colors["keyword"]["token"]:
		highlighter.add_keyword_color(keyword, colors["keyword"]["color"])
	
	# Constants
	for constant in colors["constant"]["token"]:
		highlighter.add_keyword_color(constant, colors["constant"]["color"])
	
	synt_highlighter = highlighter
	editor_ui.syntax_highlighter = highlighter


func parse_symbol_lut(json_path: String) -> void:
	var json_file: FileAccess = FileAccess.open(json_path, FileAccess.READ)
	symbols_lut = JSON.parse_string(json_file.get_as_text())


func handle_autocomplete() -> void:
	if symbols_lut == {}:
		printerr("Symbol LUT not found")
		return
	
	for fn in symbols_lut["function"]:
		editor_ui.add_code_completion_option(
			CodeEdit.KIND_FUNCTION, fn, fn+"(", highlighter_data["function"]
		)
	for constant in symbols_lut["constant"]:
		editor_ui.add_code_completion_option(
			CodeEdit.KIND_CONSTANT, constant, constant, highlighter_data["constant"]["color"]
		)
	for keyword in symbols_lut["keyword"]:
		editor_ui.add_code_completion_option(
			CodeEdit.KIND_CONSTANT, keyword, keyword, highlighter_data["keyword"]["color"]
		)
	
	editor_ui.update_code_completion_options(true)


func load_vfs_file(fpath: String, vfs: VFS) -> void:
	current_buffer["vfs"] = vfs
	current_buffer["fpath"] = fpath
	editor_ui.text = vfs.read_file(fpath)


func save_buffer() -> void:
	if not (current_buffer.has("vfs") and current_buffer.has("fpath")):
		return
	
	(current_buffer["vfs"] as VFS).write_file(current_buffer["fpath"], editor_ui.text)
