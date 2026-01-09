extends Node2D

var screen_border = Path2D.new()
var border_follow = PathFollow2D.new()

@export var border_grow : int = 32


func _ready() -> void:
	top_level = true
	call_deferred("add_child", screen_border)
	await screen_border.ready
	screen_border.call_deferred("add_child", border_follow)
	update_border()
	#queue_redraw()

#func _draw():
	#draw_polyline(screen_border.curve.get_baked_points(), Color.RED, 5)

func update_border():
	var border := Curve2D.new()
	var rect = get_resized_view_rect()
	rect.position -= Vector2.ONE * border_grow
	border.add_point(rect.position)
	border.add_point(Vector2(rect.size.x, rect.position.y))
	border.add_point(Vector2(rect.size.x, rect.size.y))
	border.add_point(Vector2(rect.position.x, rect.size.y))
	border.add_point(rect.position)
	screen_border.curve = border

func get_resized_view_rect():
	return get_viewport_rect().grow(border_grow)

func get_random_border_position() -> Vector2:
	var view_center_offset = get_resized_view_rect().size / 2
	global_position = GameManager.camera.global_position - view_center_offset
	var r = randf_range(0.0, 1.0)
	border_follow.progress_ratio = r
	return border_follow.global_position
