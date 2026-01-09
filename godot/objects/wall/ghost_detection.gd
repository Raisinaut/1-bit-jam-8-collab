extends Area2D

@onready var collision = $CollisionShape2D

func get_nearest_overlapping() -> Node2D:
	var areas = get_overlapping_areas()
	var nearest : Node2D
	#print(areas)
	if areas.size() > 0:
		nearest = areas[0]
		var shortest_distance = global_position.distance_to(nearest.global_position)
		for a in areas:
			var this_distance = global_position.distance_to(a.global_position)
			if this_distance < shortest_distance:
				shortest_distance = this_distance
				nearest = a
	return nearest

func get_range() -> float:
	return collision.shape.radius
