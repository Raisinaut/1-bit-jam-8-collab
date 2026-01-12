class_name BorderSpawner
extends Node2D

@export_category("Border")
@export var border_grow : int = 32
@export var draw_border : bool = false

@export_category("Spawning")
@export var instance_parent : Node2D
@export var scene_to_spawn : PackedScene
@export var max_instances = 1
@export var spawn_interval : float = 5.0 # seconds
@export var interval_variation : float = 1.0 # seconds

# NODES
var screen_border = Path2D.new()
var border_follow = PathFollow2D.new()
var spawn_interval_timer : SceneTreeTimer
var active_instances : Array[Node2D] = []


func _ready() -> void:
	call_deferred("add_child", screen_border)
	await screen_border.ready
	screen_border.call_deferred("add_child", border_follow)
	update_border()
	start_spawn_interval_timer()

func _process(_delta: float) -> void:
	if draw_border:
		queue_redraw()

func _draw():
	if draw_border and screen_border.curve:
		draw_polyline(screen_border.curve.get_baked_points(), Color.RED, 5)

func spawn_scene() -> void:
	if not instance_parent:
		push_error("Instance parent not provided. Scene not spawned.")
	var inst : Node2D = scene_to_spawn.instantiate()
	active_instances.append(inst)
	inst.tree_exited.connect(_on_instance_tree_exited.bind(inst))
	inst.global_position = await get_random_border_position()
	instance_parent.call_deferred("add_child", inst)

func free_active_instances() -> void:
	for inst in active_instances:
		inst.queue_free()

func update_border():
	var border := Curve2D.new()
	var rect = get_resized_view_rect()
	rect.position += Vector2.ONE * border_grow
	border.add_point(rect.position)
	border.add_point(Vector2(rect.size.x, rect.position.y))
	border.add_point(Vector2(rect.size.x, rect.size.y))
	border.add_point(Vector2(rect.position.x, rect.size.y))
	border.add_point(rect.position)
	screen_border.curve = border
	# adjust position of this node to offset toward center of view
	position = -get_view_center_offset()


# SIGNALS ----------------------------------------------------------------------
func _on_instance_tree_exited(instance) -> void:
	active_instances.erase(instance)
	if under_instance_limit():
		start_spawn_interval_timer()


# TIMERS ----------------------------------------------------------------------
func start_spawn_interval_timer() -> void:
	if not is_inside_tree():
		return
	var variation = randf_range(-interval_variation, interval_variation)
	spawn_interval_timer = get_tree().create_timer(spawn_interval + variation)
	spawn_interval_timer.timeout.connect(_on_spawn_interval_timer_timeout)

func _on_spawn_interval_timer_timeout() -> void:
	if under_instance_limit():
		spawn_scene()
		start_spawn_interval_timer()


# UTILITY ----------------------------------------------------------------------
func under_instance_limit() -> bool:
	return active_instances.size() < max_instances

func get_view_center_offset() -> Vector2:
	return get_resized_view_rect().size / 2

func get_resized_view_rect():
	return get_viewport_rect().grow(border_grow)

func get_random_border_position() -> Vector2:
	var r = randf_range(0.0, 1.0)
	if not border_follow.is_node_ready():
		await border_follow.ready
	border_follow.progress_ratio = r
	return border_follow.global_position
