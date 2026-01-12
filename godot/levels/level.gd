class_name Level
extends Node2D

@export var next_level_res: Resource

@onready var spawner = %GhostSpawner
@onready var screen_effects = $ScreenEffects

var start_grid_position : Vector2
var glitch_duration : float = 0.4

func _init() -> void:
	GameManager.level = self

func _ready() -> void:
	GameManager.player.touched_ghost.connect(_on_player_ghost_touched)
	start_grid_position = GameManager.player.grid_position
	reset_level()

var load_lock = false
func load_next_level() -> void:
	if load_lock: return # prevent this from being triggered multiple times concurrently
	load_lock = true

	if next_level_res == null:
		load_lock = false
		return

	get_tree().call_deferred("change_scene_to_packed", next_level_res)

func reset_level() -> void:
	GameManager.player.grid_position = start_grid_position
	GameManager.player.jump_to_actual_position()
	GameManager.camera.target = GameManager.player

func _on_player_ghost_touched() -> void:
	await glitch()
	reset_level()
	spawner.free_active_instances()

func glitch() -> void:
	get_tree().paused = true
	screen_effects.glitch_enabled = true
	#screen_effects.invert_enabled = true
	await get_tree().create_timer(glitch_duration).timeout
	screen_effects.glitch_enabled = false
	#screen_effects.invert_enabled = false
	get_tree().paused = false
