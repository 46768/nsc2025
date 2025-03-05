extends CodeEdit


var highlighter_json: Dictionary
var symbols_lookup: Dictionary


func _load_colors(json_path: String) -> CodeHighlighter:
	var json_file = FileAccess.open(json_path, FileAccess.READ)
	var colors = JSON.parse_string(json_file.get_as_text())
	highlighter_json = colors
	
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
	
	return highlighter


func _parse_symbol_lut(json_path: String) -> Dictionary:
	var json_file: FileAccess = FileAccess.open(json_path, FileAccess.READ)
	var lut: Dictionary = JSON.parse_string(json_file.get_as_text())
	
	return lut


func _handle_autocomplete():
	if symbols_lookup == {}:
		printerr("Symbol LUT not initialized yet")
		return
	
	for fn in symbols_lookup["function"]:
		add_code_completion_option(
			CodeEdit.KIND_FUNCTION, fn, fn+"(", highlighter_json["function"]
		)
	for constant in symbols_lookup["constant"]:
		add_code_completion_option(
			CodeEdit.KIND_CONSTANT, constant, constant, highlighter_json["constant"]["color"]
		)
	for keyword in symbols_lookup["keyword"]:
		add_code_completion_option(
			CodeEdit.KIND_CONSTANT, keyword, keyword, highlighter_json["keyword"]["color"]
		)
	
	update_code_completion_options(true)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	symbols_lookup = _parse_symbol_lut("res://assets/json/IDE/symbol_lut.json")
	syntax_highlighter = _load_colors("res://assets/json/IDE/syntax-highlighting/default.json")
