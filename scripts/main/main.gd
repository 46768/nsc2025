extends Node2D


signal main_initialized

@onready var player_ui: CanvasLayer = $UI


func _ready() -> void:
	# Variable initializations
	Globals.main = self
	Globals.player_ui = player_ui
	
	if Globals.player != null:
		Globals.player_ui.reparent(Globals.player.camera)

	main_initialized.emit()
	SignalBus.on_main_initialized.emit()
