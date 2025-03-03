extends CodeEdit


func _load_colors(json_path: String) -> CodeHighlighter:
	var json_file = FileAccess.open(json_path, FileAccess.READ)
	var json_data = JSON.parse_string(json_file.get_as_text())
	print(json_data["function"])
	
	var highlighter = CodeHighlighter.new()
	highlighter.number_color = Color("d27e99")
	highlighter.symbol_color = Color("e6c384")
	highlighter.function_color = Color("7fb4ca")
	
	highlighter.add_color_region("\"", "\"", Color("8a9a7b"), false)
	highlighter.add_color_region("'", "'", Color("8a9a7b"), false)
	highlighter.add_color_region("\"\"\"", "\"\"\"", Color("8a9a7b"), false)
	
	# Python keywords
	highlighter.add_keyword_color("for", Color("8992a7"))
	highlighter.add_keyword_color("in", Color("8992a7"))
	highlighter.add_keyword_color("while", Color("8992a7"))
	
	# Constants
	highlighter.add_keyword_color("True", Color("b6927b"))
	highlighter.add_keyword_color("False", Color("b6927b"))
	
	return highlighter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	syntax_highlighter = _load_colors("res://assets/json/IDE/syntax-highlighting/default.json")
