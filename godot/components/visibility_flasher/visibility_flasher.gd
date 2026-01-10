class_name VisibilityFlasher
extends Node

var flash := false : set = set_flash
var active := false : set = set_active

signal flashed

@export var flash_interval := 0.05
@export var linked_node : Node
@export var affect_self_modulate : bool = false

var time_since_flash : float = 0.0 # track time


func set_flash(state):
	flash = state
	if flash:
		flashed.emit()
	var flash_alpha = int(not flash)
	if affect_self_modulate:
		linked_node.self_modulate.a = flash_alpha
	else:
		linked_node.modulate.a = flash_alpha

func _process(delta: float) -> void:
	if not active:
		return
	time_since_flash += delta
	if time_since_flash > flash_interval:
		flash = not flash
		time_since_flash = 0.0

func set_active(state : bool) -> void:
	active = state
	if active:
		time_since_flash = 0.0
	else:
		flash = false
