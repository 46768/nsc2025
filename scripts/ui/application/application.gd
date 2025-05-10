extends VBoxContainer


@onready var content: PanelContainer = $Content

var app_instance_ref: ApplicationInstance
var app_name: String = "N/A"
var app_icon: Texture2D


func _ready() -> void:
	$Topbar/C/Title/Name.set_text(app_name)
	$Topbar/C/Title/Icon.set_texture(app_icon)
	
	$Topbar/C/Control/Minimize.pressed.connect(app_instance_ref.minimize)
	$Topbar/C/Control/Maximize.pressed.connect(app_instance_ref.maximize)
	$Topbar/C/Control/Close.pressed.connect(app_instance_ref.close)
	
