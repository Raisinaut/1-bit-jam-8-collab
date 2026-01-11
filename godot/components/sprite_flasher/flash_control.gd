class_name FlashControl
extends Node

var flash := false : set = set_flash
var active := false : set = set_active

@export var flash_interval := 0.05
@export var flash_intensity := 1.0

@onready var linked_node = self

var time_since_flash : float = 0.0 # track time

func set_color_override_amount(value):
	linked_node.material.set_shader_parameter("flash_amount", value)

func set_flash(state):
	flash = state
	set_color_override_amount(int(flash) * flash_intensity)

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
