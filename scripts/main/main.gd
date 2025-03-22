extends Node2D


signal main_initialized

@onready var test_texture: Texture2D = preload("res://assets/textures/placeholder.jpg")
@onready var player_ui: CanvasLayer = $UI
@onready var ide_ui: Control = $UI/Ide

var test_seq: Sequence


func _ready() -> void:
	# Variable initializations
	Globals.main = self
	Globals.player_ui = player_ui
	
	if Globals.player != null:
		Globals.player_ui.reparent(Globals.player.camera)
	
	ide_ui.hide()

	main_initialized.emit()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ToggleIDE"):
		ide_ui.set_visible(not ide_ui.is_visible())


func _on_ide_initialized(__: VFS) -> void:
	await Globals.wait(1)
	
	var fibo: Sequence = Sequence.new()
	
	fibo.load_source("""
	mov $d.0, $m.counter
	mov $d.0, $m.reg1
	mov $d.1, $m.reg2
	
	loop:
		cmp %.counter, $d.25
		je exit
		mov %.reg1, $m.temp
		mov %.reg2, $m.reg1
		mov %.temp, $m.reg2
		add %.reg1, $m.reg2
		dialogue %.reg1
		wait_sig %.latestDialogueClosedSig
		inc $m.counter
		jmp loop
	
	exit:
		cpu_halt
	""")
	
	fibo.next()
