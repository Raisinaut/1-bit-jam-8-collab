class_name ShakyCamera
extends Camera2D

@export var can_pivot := false
@export_range (0.0, 0.1, 0.01) var pivot_amount = 0.04
@export_range (0.0, 0.1, 0.005) var pivot_speed = 0.01
@onready var shaker = $Shaker
@onready var initial_position = global_position

var target : Node2D

func _ready() -> void:
	GameManager.camera = self

func small_shake() -> void:
	shaker.start(0.3, 30, 10, 0)

func _process(delta: float) -> void:
	global_position = lerp(global_position, target.global_position, delta * 10)

func spin():
	ignore_rotation = false
	rotation = 0
	var t = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(self, "rotation", 2 * PI * 2, 1.8)

func pivot(toward_pos : Vector2):
	var pivot_vector = (initial_position - toward_pos) * pivot_amount
	global_position = lerp(global_position, initial_position - pivot_vector, pivot_speed)
