class_name GridObject
extends Node2D

@export var vulnerable := false
@export var health := 0
@export var contact_damage := 0
@export var grid_offset := Vector2.ZERO

var _grid = null

var grid_position = Vector2.ZERO
var move_direction = Vector2.ZERO

var move_tween : Tween
var bonk_tween : Tween

func _init() -> void:
	initialize_grid(GameManager.grid_node)

func initialize_grid(grid: GridNode):
	_grid = grid
	await ready
	grid_position = round((global_position - _grid.grid_origin) / _grid.grid_step)
	global_position = _actual_position()

func attempt_move(direction: Vector2):
	if is_moving(): return
	if direction == Vector2.ZERO: return
	direction = grid_round(direction)
	var object = _grid.get_grid_position(grid_position + direction)
	if !object:
		grid_position += direction
		move()
	else:
		_bonk(direction)
		move_direction = Vector2.ZERO

func move() -> void:
	if move_tween : move_tween.kill()
	move_tween = create_tween()
	move_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	move_tween.tween_property(self, "global_position", _actual_position(), 0.25)

func _actual_position():
	return (grid_position * _grid.grid_step) + _grid.grid_origin + grid_offset

func _bonk(direction: Vector2):
	if direction == Vector2.ZERO: return
	var bonk = direction * _grid.grid_step * 0.2
	if bonk_tween:
		bonk_tween.kill()
	bonk_tween = create_tween()
	bonk_tween.tween_property(self, 'global_position', _actual_position() + bonk, 0.05)
	bonk_tween.tween_property(self, 'global_position', _actual_position(), 0.05)

func take_damage(amount: int):
	if !vulnerable: return
	health -= amount
	if health <= 0: die()

func die():
	queue_free()

func grid_round(vec: Vector2):
	vec = round(vec.normalized())
	if vec.x != 0 && vec.y != 0: vec.x = 0
	return vec

func is_moving() -> bool:
	return move_tween and move_tween.is_running()
