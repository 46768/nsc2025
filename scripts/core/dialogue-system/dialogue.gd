extends Node


const DIALOGUE: PackedScene = preload("res://scenes/DialogueBox.tscn")

var current_dialogue: Dictionary[String, Node] = {}


func spawn_dialogue(message: String, texture: Texture2D=null) -> String:
	var dialogue: Node = DIALOGUE.instantiate()
	var dialogue_hash: String = (
			message + Time.get_datetime_string_from_system()).sha256_text()
	dialogue.dialogue_message = message
	dialogue.dialogue_hash = dialogue_hash
	if not texture == null:
		dialogue.dialogue_texture = texture
	
	Globals.main.add_child(dialogue)
	current_dialogue[dialogue_hash] = dialogue
	
	return dialogue_hash


func delete_dialogue(dialogue_hash: String) -> void:
	if not current_dialogue.has(dialogue_hash):
		printerr("Dialogue '%s' does not exists" % dialogue_hash)
		return
	
	var deleting_dialogue: Node = current_dialogue[dialogue_hash]
	deleting_dialogue.cleanup()
	deleting_dialogue.queue_free()
	current_dialogue.erase(dialogue_hash)


func clear_dialogue() -> void:
	for dialogue_hash: String in current_dialogue:
		Dialogue.delete_dialogue(dialogue_hash)
