class_name Projectile
extends Area2D

var speed : float = 2000
var direction := Vector2.ZERO

func _ready() -> void:
	top_level = true
	rotation = direction.angle()

func _process(delta: float) -> void:
	global_position += speed * direction * delta
