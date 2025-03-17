extends Node2D


@onready var test_texture: Texture2D = preload("res://assets/textures/placeholder.jpg")

var test_seq: Sequence


func _ready() -> void:
	# Variable initializations
	Globals.main = self
	
	$Ide.hide()
	
	
	
	Dialogue.spawn_dialogue("[wave]Test test hello world![/wave]", test_texture)
	await Globals.wait(1)
	Dialogue.clear_dialogue()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ToggleIDE"):
		$Ide.set_visible(not $Ide.is_visible())


func _on_ide_initialized(__: VFS) -> void:
	await Globals.wait(1)
	
	var test_sequence: Sequence = Sequence.new()
	
	# Write initial RAM
	test_sequence.ram["dtex"] = test_texture
	test_sequence.ram["intro1_txt"] = "Oh hello there! So i'll teach you python's print function today"
	test_sequence.ram["intro2_txt"] = "So, press [code]Shift + i[/code] to bring up the editor"
	test_sequence.ram["setup1_txt"] = "Ok so i setted up a simple script for you here"
	test_sequence.ram["explain1_txt"] = "So the text thats Im highlighting is a print statement, it's a thing that simply output stuff you give it to the console"
	test_sequence.ram["demonst1_txt"] = "Here, I ran the code for you here, you should see in the console there's a [code]Hello World![/code]"
	test_sequence.ram["explain2_txt"] = "So what's happening is that the [code]print[/code] is taking what it's given, which Im highlighting is the string \"Hello World!\" to the console"
	test_sequence.ram["demonst2_txt"] = "Here's another example, this time with a number, I've run the program and you should see [code]1234[/code] in the console"
	test_sequence.ram["explain3_txt"] = "Here, [code]1234[/code] is what we gave print, so print outputs it to the console, pretty cool right?"
	
	test_sequence.ram["sample_program1"] = "print(\"Hello World!\")"
	test_sequence.ram["sample_program2"] = "print(1234)"
	
	test_sequence.ram["man_print"] = """The print function is a function that prints some value to the output or in our environment, the console. The function takes in any amount of values and when printing it will print each value separated by a space, so for example

[code]print(\"Hello World\", \"This is print\")[/code]

will results in

[code]Hello World This is print[/code]

in the console
"""
	
	# Intro
	var seq_group1: Variant = test_sequence.new_group()
	seq_group1.parse_source("""
		dialogue~%intro1_txt~%dtex
	""")
	
	# Intro2
	var seq_group2: Variant = test_sequence.new_group()
	seq_group2.parse_source("""
		dialogue~%intro2_txt~%dtex
	""")
	# Setup1
	var seq_group3: Variant = test_sequence.new_group()
	seq_group3.parse_source("""
		shell_s~$s.touch main.py
		shell_s~$s.write main.py~%sample_program1
		shell_s~$s.code main.py
		set_statement~%man_print
		dialogue~%setup1_txt~%dtex
	""")
	# Explain1
	var seq_group4: Variant = test_sequence.new_group()
	seq_group4.parse_source("""
		highlight_buffer~$d.0~$d.0~$d.0~$d.21
		dialogue~%explain1_txt~%dtex
	""")
	# Demonst1
	var seq_group5: Variant = test_sequence.new_group()
	seq_group5.parse_source("""
		shell~$s.python main.py
		dialogue~%demonst1_txt~%dtex
	""")
	# Explain2
	var seq_group6: Variant = test_sequence.new_group()
	seq_group6.parse_source("""
		highlight_buffer~$d.0~$d.6~$d.0~$d.20
		dialogue~%explain2_txt~%dtex
	""")
	# Demonst2
	var seq_group7: Variant = test_sequence.new_group()
	seq_group7.parse_source("""
		highlight_buffer~$d.0~$d.0~$d.0~$d.0
		shell_s~$s.write main.py~%sample_program2
		shell~$s.python main.py
		dialogue~%demonst2_txt~%dtex
	""")
	# Explain3
	var seq_group8: Variant = test_sequence.new_group()
	seq_group8.parse_source("""
		highlight_buffer~$d.0~$d.6~$d.0~$d.10
		dialogue~%explain3_txt~%dtex
	""")
	# Cleanup
	var seq_group9: Variant = test_sequence.new_group()
	seq_group9.parse_source("""
		clear_highlight
	""")
	
	# Run sequence
	test_sequence.next()
	
	# Callback hell
	test_sequence.ram["latestDialogue"].dialogue_closed.connect(func()->void:
		test_sequence.next()
		test_sequence.ram["latestDialogue"].dialogue_closed.connect(func()->void:
			test_sequence.next()
			test_sequence.ram["latestDialogue"].dialogue_closed.connect(func()->void:
				test_sequence.next()
				test_sequence.ram["latestDialogue"].dialogue_closed.connect(func()->void:
					test_sequence.next()
					test_sequence.ram["latestDialogue"].dialogue_closed.connect(func()->void:
						test_sequence.next()
						test_sequence.ram["latestDialogue"].dialogue_closed.connect(func()->void:
							test_sequence.next()
							test_sequence.ram["latestDialogue"].dialogue_closed.connect(func()->void:
								test_sequence.next()
								test_sequence.ram["latestDialogue"].dialogue_closed.connect(func()->void:
									test_sequence.next()
									while test_sequence.next(): pass
								)
							)
						)
					)
				)
			)
		)
	)
	
