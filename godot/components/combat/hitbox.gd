# Detected by HurtBox
class_name HitBox
extends Area2D

@warning_ignore("unused_signal")
signal detected # not ideal, but signal is triggered from the hurtbox class >_>

@export var damage := 1
@export var knockback := 10

var disabled = false : set = set_disabled

func _init() -> void:
	set_collision_layer_value(7, true)

func set_disabled(state):
	disabled = state
	set_deferred("monitorable", not disabled)
