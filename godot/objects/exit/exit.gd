class_name Exit
extends GridObject

@onready var sprite = $Sprite2D
@onready var sprite_fill = $Sprite2D/SpriteFill
@onready var shaker = $Shaker
@onready var projectile_detection = $ProjectileDetection
@onready var ghost_detection = $GhostDetection
@onready var visibility_timer = $VisibilityTimer
@onready var hum_sfx = $HumSFX

var fade_time: float = 3.0 # seconds
var fade_using_fill : bool = true

func _ready() -> void:
	visibility_timer.wait_time = fade_time
	visibility_timer.one_shot = true
	projectile_detection.area_entered.connect(_on_projectile_detection_area_entered)
	hum_sfx.volume_db = -60
	hum_sfx.play()

func _process(delta: float) -> void:
	ghost_shake()
	update_fade()
	update_hum_volume(delta)

func _on_projectile_detection_area_entered(area : Area2D) -> void:
	area.queue_free()
	illuminate()

func illuminate() -> void:
	shaker.start(0.1)
	reset_visibility_timer()

func reset_visibility_timer() -> void:
	visibility_timer.start()

func get_fade_progress_value() -> float:
	return visibility_timer.time_left / visibility_timer.wait_time

func ghost_shake():
	var prox_value = get_ghost_proximity_value()
	if prox_value <= 0:
		return
	var shake_duration = lerp(0.0, 0.2, prox_value)
	var shake_amplitude = lerp(0.0, 60.0, prox_value)
	var shake_frequency = lerp(10.0, 30.0, prox_value)
	shaker.start(shake_duration, shake_frequency, shake_amplitude)

func get_ghost_proximity_value() -> float:
	var ghost : Ghost = ghost_detection.get_nearest_overlapping()
	if not ghost:
		return 0.0
	var ghost_dist = global_position.distance_to(ghost.global_position)
	var detection_range = ghost_detection.get_range()
	var proximity : float = remap(ghost_dist, 0.0, detection_range, 1.0, 0.0)
	return clamp(proximity, 0, 1.0)

func update_fade() -> void:
	var ghost_fade_value = lerp(0.0, 0.5, get_ghost_proximity_value())
	var fade_value = max(get_fade_progress_value(), ghost_fade_value)
	if fade_using_fill:
		# set fill scale (sprite edge will match collision)
		sprite_fill.scale = Vector2.ONE * lerp(1.0, 0.8, fade_value)
		sprite_fill.offset = sprite.offset
	else:
		sprite_fill.hide()
		# set sprite (sprite edge will not match collision)
		sprite.scale = Vector2.ONE * lerp(0.0, 1.0, fade_value)
		sprite.visible = fade_value > 0.0
	

func update_hum_volume(delta: float) -> void:
	var ghost_fade_value = lerp(0.0, 0.5, get_ghost_proximity_value())
	var fade_value = max(get_fade_progress_value(), ghost_fade_value)
	var target_volume = lerp(-60.0, -10.0, fade_value)
	hum_sfx.volume_db = lerp(hum_sfx.volume_db, target_volume, delta * 100)
