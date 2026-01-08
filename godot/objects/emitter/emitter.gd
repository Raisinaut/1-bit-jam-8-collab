extends Node2D

@export var emission_scene : PackedScene

func emit(direction : Vector2) -> void:
	var inst : Projectile = emission_scene.instantiate()
	call_deferred("add_child", inst)
	inst.global_position = global_position
	inst.direction = direction
