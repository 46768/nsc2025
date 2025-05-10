extends VBoxContainer


@onready var content: PanelContainer = $Content

var app_instance_ref: WeakRef
var app_name: String = "N/A"
var app_icon: Texture2D


func _ready() -> void:
	$Topbar/C/Title/Name.set_text(app_name)
	$Topbar/C/Title/Icon.set_texture(app_icon)
