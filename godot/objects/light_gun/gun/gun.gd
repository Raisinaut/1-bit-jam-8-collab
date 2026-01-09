@tool
extends Node2D

@onready var emitter = %Emitter

@export_range(0, 96) var reticle_distance : int = 48 : set = set_reticle_distance
@export_range(0, 2*PI) var spread_angle : float = PI/2
@export_range(1, 1000) var emission_count : int = 200

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("fire"):
		fire()

func fire() -> void:
	var start_angle = -spread_angle / 2
	var angle_interval = spread_angle / emission_count
	for i in emission_count:
		var angle_offset : float = angle_interval * i
		emitter.emit(Vector2.from_angle(rotation + start_angle + angle_offset))

func set_reticle_distance(value : int) -> void:
	if $Reticle != null:
		reticle_distance = value
		$Reticle.position.x = reticle_distance
