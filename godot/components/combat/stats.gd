class_name Stats
extends Node

signal hp_depleted
signal hp_gained
signal hp_lost
signal hp_changed(hp_value)

@export var max_hp : int = 100

@onready var hp : float = max_hp : set = set_hp # set onready to keep export value


func set_hp(value):
	value = clamp(value, 0, max_hp)
	if hp == value:
		return
	
	# Set hp
	var original_hp = hp
	hp = value
	
	# Emit signals
	if value < original_hp:
		hp_lost.emit()
	elif value > original_hp:
		hp_gained.emit()
	hp_changed.emit(hp)
	
	if hp <= 0:
		hp_depleted.emit()

func get_hp_percent():
	return hp / float(max_hp)

func take_damage(amount : float):
	hp -= amount

func get_missing_hp():
	return max_hp - hp
