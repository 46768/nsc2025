extends StaticBody2D


@export var npc_data_resource: JSON = null
@export var npc_texture: Texture2D:
	set(texture):
		npc_texture = texture
		$Sprite2D.set_texture(texture)

@onready var interaction_text: Label = $Label

var npc_data: Dictionary
var interact_key: StringName
var npc_problem: ProblemClass = ProblemClass.new(
		"testProblem", VFS.new())

var text_shift: int = 192


func _ready() -> void:
	npc_data = npc_data_resource.data
	
	interact_key = StringName(npc_data.get("interactKey", "<null>"))
	
	interaction_text.set_text(npc_data.get("interactText", "<null>"))
	_on_screen_resize()
	
	Globals.screen_resized.connect(_on_screen_resize)
	SignalBus.on_main_initialized.connect(
			func()->void: )


func _on_main_initialized() -> void:
	interaction_text.reparent(Globals.player_ui)

	var seq: Sequence = npc_problem.sequence
	
	seq.write_rom("hello1", "Hey Hello there!")
	seq.write_rom("hello2", "So I'll teach you about the print function!")
	seq.write_rom("open_edit", "Alright so open the editor using shift + i")
	seq.write_rom("editor_tuto", "So this is the editor, this is where you edit code")
	seq.write_rom("tutor1", "Alright so the print functions takes in stuff and output it")
	seq.write_rom("tutor2", "Basically printing it, so heres an example")
	seq.write_rom("tutor3", "So running the code here will get you a hello world in the console below")
	seq.write_rom("tutor4", "See how the Hello World! in the print function is outputed to the console?")
	seq.write_rom("tutor5", "Basically that's how print works, just prints whatever you gives it")
	seq.write_rom("tutor6", "Try chaninging the value in the print function, type next in the console when you want to continue on with the lesson, you can run python file by running python and adding a space then the file name after it")
	seq.write_rom("tutor7", "ok ready for the test? well here we go!, the task should be on the left, you can test your code using the test command")
	seq.write_rom("end1", "nice!, so i think you got the gist of print function now")
	seq.write_rom("statement_text", """Write a python script that prints

Boat goes binted!!!
""")
	
	seq.write_rom("sample_program", "print(\"Hello World!\")")
	
	seq.write_rom("next_sig", Globals.ide.shell.signal_reg["next_sig"])
	seq.write_rom("test_sig", Globals.ide.shell.signal_reg["test_sig"])
	
	seq.load_source("""
		dialogue %hello1
		wait_sig %.latestDialogueClosedSig
		
		dialogue %hello2
		wait_sig %.latestDialogueClosedSig
		
		dialogue %open_edit
		wait_sig %.latestDialogueClosedSig
		
		shell_s $s.touch, $s.main.py
		shell_s $s.code, $s.main.py
		dialogue %editor_tuto
		wait_sig %.latestDialogueClosedSig
		
		dialogue %tutor1
		wait_sig %.latestDialogueClosedSig
		
		shell_s $s.write, $s.main.py, %sample_program
		dialogue %tutor2
		wait_sig %.latestDialogueClosedSig
		
		shell $s.python, $s.main.py
		dialogue %tutor3
		wait_sig %.latestDialogueClosedSig
		
		IDE::highlight_buffer $d.0, $d.6, $d.0, $d.20
		dialogue %tutor4
		wait_sig %.latestDialogueClosedSig
		
		IDE::clear_highlight
		dialogue %tutor5
		wait_sig %.latestDialogueClosedSig
		
		dialogue %tutor6
		wait_sig %next_sig
		
		dialogue %tutor7
		wait_sig %.latestDialogueClosedSig
		IDE::set_statement %statement_text
		wait_sig %test_sig
		dialogue %end1
	""")


func _on_screen_resize() -> void:
	# Center -> like 128 px down
	var screen_size: Vector2 = Globals.screen_size
	var screen_center: Vector2 = screen_size / 2
	
	@warning_ignore("integer_division")
	interaction_text.set_position(Vector2(0, screen_center.y+(text_shift/2)))
	interaction_text.set_size(Vector2(screen_size.x, 128)) # Set full screen wide


func _interact(get_keybind: bool, cleanup: bool) -> StringName:
	if get_keybind:
		# Put code for when adding interaction
		interaction_text.show()
		return interact_key
	
	if cleanup:
		# Put code for when removing interaction
		interaction_text.hide()
		return &""
	
	# Put code for interaction here
	print("NPC interacted")
	if not npc_problem.is_running:
		npc_problem.start()

	return &""
