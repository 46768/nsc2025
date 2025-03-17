class_name EditorManager
extends Object


var editor_ui: CodeEdit
var highlighter_data: Dictionary; var synt_highlighter: CodeHighlighter
var symbols_lut: Dictionary
var current_buffer: Dictionary
var refresh_sig_handler: Callable

func _init(edit_ui: CodeEdit) -> void:
	editor_ui = edit_ui
	
	editor_ui.set_line_folding_enabled(true)
	editor_ui.set_auto_brace_completion_enabled(true)
	editor_ui.set_highlight_matching_braces_enabled(true)
	editor_ui.set_draw_line_numbers(true)
	editor_ui.set_code_completion_enabled(true)
	editor_ui.set_auto_indent_enabled(true)
	editor_ui.set_draw_tabs(true)
	editor_ui.set_line_length_guidelines([80, 100])
	
	load_colors("res://assets/json/IDE/syntax-highlighting/default.json")
	parse_symbol_lut("res://assets/json/IDE/symbol_lut.json")
	
	editor_ui.code_completion_requested.connect(handle_autocomplete)
	editor_ui.text_changed.connect(handle_autocomplete)
	editor_ui.text_changed.connect(save_buffer)


func load_colors(json_path: String) -> void:
	var json_file: FileAccess = FileAccess.open(json_path, FileAccess.READ)
	var colors: Dictionary = JSON.parse_string(json_file.get_as_text())
	highlighter_data = colors
	
	var highlighter: CodeHighlighter = CodeHighlighter.new()
	highlighter.number_color = colors["number"]
	highlighter.symbol_color = colors["symbol"]
	highlighter.function_color = colors["function"]
	
	for str_token: String in colors["string"]["token"]:
		highlighter.add_color_region(
			str_token, str_token, 
			colors["string"]["color"], false
		)
	
	# Python keywords
	for keyword: String in colors["keyword"]["token"]:
		highlighter.add_keyword_color(keyword, colors["keyword"]["color"])
	
	# Constants
	for constant: String in colors["constant"]["token"]:
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
	
	for fn: String in symbols_lut["function"]:
		editor_ui.add_code_completion_option(
			CodeEdit.KIND_FUNCTION, fn, fn+"(", highlighter_data["function"]
		)
	for constant: String in symbols_lut["constant"]:
		editor_ui.add_code_completion_option(
			CodeEdit.KIND_CONSTANT, constant, constant, highlighter_data["constant"]["color"]
		)
	for keyword: String in symbols_lut["keyword"]:
		editor_ui.add_code_completion_option(
			CodeEdit.KIND_CONSTANT, keyword, keyword, highlighter_data["keyword"]["color"]
		)
	
	editor_ui.update_code_completion_options(true)


func load_vfs_file(fpath: String, vfs: VFS) -> void:
	current_buffer["vfs"] = vfs
	current_buffer["fpath"] = fpath
	var caret_line: int = editor_ui.get_caret_line()
	var caret_column: int = editor_ui.get_caret_column()
	editor_ui.text = vfs.read_file(fpath)
	editor_ui.set_caret_column(caret_column)
	editor_ui.set_caret_line(caret_line)


func reload_data() -> void:
	var caret_line: int = editor_ui.get_caret_line()
	var caret_column: int = editor_ui.get_caret_column()
	editor_ui.text = current_buffer["vfs"].read_file(current_buffer["fpath"])
	editor_ui.set_caret_column(caret_column)
	editor_ui.set_caret_line(caret_line)


func save_buffer() -> void:
	if not (current_buffer.has("vfs") and current_buffer.has("fpath")):
		return
	
	(current_buffer["vfs"] as VFS).write_file(current_buffer["fpath"], editor_ui.text)
