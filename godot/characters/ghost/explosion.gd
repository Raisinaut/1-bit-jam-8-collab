extends Node2D

@onready var emitter = $Emitter

@export_range(1, 1000) var emission_count : int = 300

func _ready() -> void:
	activate()

func activate() -> void:
	var start_angle = 0
	var angle_interval = 2 * PI / emission_count
	for i in emission_count:
		var angle_offset : float = angle_interval * i
		emitter.emit(Vector2.from_angle(start_angle + angle_offset))
