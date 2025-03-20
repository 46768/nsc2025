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
	
	var fibo: Sequence = Sequence.new()
	
	fibo.load_source("""
	mov $d.0, $m.counter
	mov $d.0, $m.reg1
	mov $d.1, $m.reg2
	
	loop:
		cmp %.counter, $d.25
		je >exit
		mov %.reg1, $m.temp
		mov %.reg2, $m.reg1
		mov %.temp, $m.reg2
		add %.reg1, $m.reg2
		dialogue %.reg1
		wait_sig %.latestDialogueClosedSig
		inc $m.counter
		jmp >loop
	
	exit:
		cpu_halt
	""")
	
	fibo.next()
