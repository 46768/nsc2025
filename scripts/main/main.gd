extends Node2D


@onready var test_texture: Texture2D = preload("res://assets/textures/placeholder.jpg")

var test_seq: Sequence


func _ready() -> void:
	# Variable initializations
	Globals.main = self
	
	$Ide.hide()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ToggleIDE"):
		$Ide.set_visible(not $Ide.is_visible())


func _on_ide_initialized(__: VFS) -> void:
	await Globals.wait(1)
	
	Problem.create("TestProblem", VFS.new())
	var problem: ProblemClass = Problem.loaded_problem["TestProblem"]
	var test_sequence: Sequence = problem.sequence
	
	# Write initial RAM
	test_sequence.write_rom("intro1_txt", "Oh hello there! So I'll teach you Python's print function today")
	test_sequence.write_rom("intro2_txt", "So, press [code]Shift + i[/code] to bring up the editor")
	test_sequence.write_rom("setup1_txt", "Ok so I set up a simple script for you here")
	test_sequence.write_rom("explain1_txt", "So the text that I'm highlighting is a print statement, it's a thing that simply outputs stuff you give it to the console")
	test_sequence.write_rom("demonst1_txt", "Here, I ran the code for you, you should see in the console there's a [code]Hello World![/code]")
	test_sequence.write_rom("explain2_txt", "So what's happening is that the [code]print[/code] is taking what it's given, which I'm highlighting is the string \"Hello World!\" to the console")
	test_sequence.write_rom("demonst2_txt", "Here's another example, this time with a number, I've run the program and you should see [code]1234[/code] in the console")
	test_sequence.write_rom("explain3_txt", "Here, [code]1234[/code] is what we gave print, so print outputs it to the console, pretty cool right?")

	test_sequence.write_rom("sample_program1", "print(\"Hello World!\")")
	test_sequence.write_rom("sample_program2", "print(1234)")

	test_sequence.write_rom("man_print", """The print function is a function that prints some value to the output or, in our environment, the console. The function takes in any amount of values, and when printing it will print each value separated by a space, so for example

[code]print(\"Hello World\", \"This is print\")[/code]

will result in

[code]Hello World This is print[/code]

in the console
""")

	
	test_sequence.load_source("""
	; Intro
		dialogue~%intro1_txt
		wait_sig~%.latestDialogueClosedSig
	
	; Intro2
		dialogue~%intro2_txt
		wait_sig~%.latestDialogueClosedSig
	
	; Setup1
		shell_s~$s.touch main.py
		shell_s~$s.write main.py~%sample_program1
		shell_s~$s.code main.py
		IDE::set_statement~%man_print
		dialogue~%setup1_txt
		wait_sig~%.latestDialogueClosedSig
	
	; Explain1
		IDE::highlight_buffer~$d.0~$d.0~$d.0~$d.21
		dialogue~%explain1_txt
		wait_sig~%.latestDialogueClosedSig
		
	; Demonst1
		shell~$s.python main.py
		dialogue~%demonst1_txt
		wait_sig~%.latestDialogueClosedSig
	
	; Explain2
		IDE::highlight_buffer~$d.0~$d.6~$d.0~$d.20
		dialogue~%explain2_txt
		wait_sig~%.latestDialogueClosedSig
	
	; Demonst2
		IDE::highlight_buffer~$d.0~$d.0~$d.0~$d.0
		shell_s~$s.write main.py~%sample_program2
		shell~$s.python main.py
		dialogue~%demonst2_txt
		wait_sig~%.latestDialogueClosedSig
	
	; Explain3
		IDE::highlight_buffer~$d.0~$d.6~$d.0~$d.10
		dialogue~%explain3_txt
		wait_sig~%.latestDialogueClosedSig
		
	; Cleanup
		IDE::clear_highlight
	""")
	
	var serialized: String = Problem.serialize_loaded_problem("TestProblem")
	var unserialzied: ProblemClass = Problem.load_from_string(serialized)
	problem.prnt()
	unserialzied.prnt()
