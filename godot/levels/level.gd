class_name Level
extends Node2D

@export var next_level_res: Resource

func _init() -> void:
	GameManager.level = self

var load_lock = false
func load_next_level() -> void:
	if load_lock: return # prevent this from being triggered multiple times concurrently
	load_lock = true

	if next_level_res == null:
		load_lock = false
		return

	get_tree().call_deferred("change_scene_to_packed", next_level_res)
