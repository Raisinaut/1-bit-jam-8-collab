extends GridCharacter

var target = Vector2.ZERO

func _move_towards_target():
	attempt_move(grid_round(grid_position.direction_to(target)))
