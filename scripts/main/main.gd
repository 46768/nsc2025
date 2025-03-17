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
	test_seq = Sequence.new()
	
	test_seq.ram["test label"] = "mkdir test"
	test_seq.ram["statement"] = """Hello! This is a test statement!
So this is the print function [code]print[/code]
It prints what we gives it, so for example [code]print(\"Hello!\")[/code]
will print [code]Hello![/code] to the console you have below.
Try running the program with [code]python main.py[/code] using the
input line below!
"""
	test_seq.ram["sample_program"] = "print(\"Hello!\")"
	
	var seq_grp: Variant = test_seq.new_group()
	
	seq_grp.parse_source("""
		mov~$s.touch main.py~$m.move test
		shell~$s.ls                    ; Test comment
		shell~%test label
		shell~$s.cd test
		shell~%.move test
		shell~$s.write main.py~%sample_program
		shell~$s.code main.py
		set_statement~%statement
	""")
	
	var seq_grp2: Variant = test_seq.new_group()
	
	seq_grp2.parse_source("""
		dialogue~$s.[wave][color=red]Hello from DSL![/color][/wave]
	""")
	
	test_seq.next()
	test_seq.next()
