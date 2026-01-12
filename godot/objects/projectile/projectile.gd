class_name Projectile
extends Area2D

@onready var hitbox = $HitBox

var speed : float = 2000
var direction := Vector2.ZERO

func _ready() -> void:
	top_level = true
	rotation = direction.angle()
	hitbox.detected.connect(_on_hitbox_detected) # delete when detected

func _process(delta: float) -> void:
	global_position += speed * direction * delta

func _on_hitbox_detected(_by_hurtbox : HurtBox) -> void:
	queue_free()
