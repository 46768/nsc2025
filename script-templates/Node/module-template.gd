# meta-name: COSH Shell Module
# meta-description: A COSH shell module template

class_name COSHModuleTemplate
extends COSHModule


func _init() -> void:
	module_name = ""
	commands = {}
	signals = {}
