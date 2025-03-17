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
	
	var seq_grp = test_seq.new_group()
	
	seq_grp.parse_source("""
		mov~$s.touch main.py~$m.move test
		shell~$s.ls                    ; Test comment
		shell~%test label
		shell~$s.cd test
		shell~%.move test
		shell~$s.code main.py
	""")
	
	var seq_grp2 = test_seq.new_group()
	
	seq_grp2.parse_source("""
		mov~$m.reg2~$m.reg1
		mov~%.reg1~$m.reg3
		mov~$s.echo test~%.reg3
		shell~%.reg2
		shell~%.reg1
		dialogue~$s.[wave][color=red]Hello from DSL![/color][/wave]
	""")
	
	test_seq.next()
	test_seq.next()
