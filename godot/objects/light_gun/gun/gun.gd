@tool
class_name Gun
extends Node2D

const MAX_OVERHEAT : float = 1.0

signal overheat_amount_changed(overheat_amount)
signal overheat_started
signal overheat_ended

@onready var emitter = %Emitter
@onready var fire_sfx = $FireSFX
@onready var overheat_sfx = $OverheatSFX

@export_range(0, 96) var reticle_distance : int = 48 : set = set_reticle_distance
@export_range(0, 2*PI) var spread_angle : float = PI/4
@export_range(1, 1000) var emission_count : int = 100
@export_range(0.05, 0.5) var emission_interval : float = 0.2
@export_range(0.5, 5.0) var overheat_duration : float = 3.0

var interval_timer : SceneTreeTimer
var overheat_timer : SceneTreeTimer

var overheat_amount : float = 0.0 : set = set_overheat_amount
var overheat_decay : float = 0.5
var overheat_per_shot : float = 0.25


func _ready() -> void:
	GameManager.gun = self

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	look_at(get_global_mouse_position())
	
	if is_overheating():
		return
		
	decay_overheat(delta)
	if Input.is_action_pressed("fire") or Input.is_action_just_pressed("fire"):
		fire()

func fire() -> void:
	if is_interval_active():
		return
	start_interval_timer()
	increase_overheat()
	fire_sfx.play()
	# Set up and emit projectile
	var start_angle = -spread_angle / 2
	var angle_interval = spread_angle / emission_count
	for i in emission_count:
		var angle_offset : float = angle_interval * i
		emitter.emit(Vector2.from_angle(rotation + start_angle + angle_offset))

func decay_overheat(delta : float) -> void:
	overheat_amount -= overheat_decay * delta

func increase_overheat() -> void:
	overheat_amount += overheat_per_shot

func cooldown() -> void:
	var t = create_tween()
	t.tween_method(set_overheat_amount, overheat_amount, 0.0, overheat_duration)

func overheat() -> void:
	overheat_sfx.play()
	cooldown()
	start_overheat_timer()

# SETTERS ----------------------------------------------------------------------
func set_reticle_distance(value : int) -> void:
	if $Reticle != null:
		reticle_distance = value
		$Reticle.position.x = reticle_distance

func set_overheat_amount(value : float ) -> void:
	overheat_amount = value
	overheat_amount = clamp(overheat_amount, 0.0, MAX_OVERHEAT)
	if overheat_amount >= MAX_OVERHEAT:
		overheat()
	overheat_amount_changed.emit(overheat_amount)


# TIMER MANAGEMENT -------------------------------------------------------------
func start_interval_timer() -> void:
	interval_timer = get_tree().create_timer(emission_interval)

func start_overheat_timer() -> void:
	overheat_timer = get_tree().create_timer(overheat_duration)
	overheat_started.emit()
	overheat_timer.timeout.connect(overheat_ended.emit)


# CHECKS -----------------------------------------------------------------------
func is_interval_active() -> bool:
	return interval_timer and interval_timer.time_left

func is_overheating() -> bool:
	return overheat_timer and overheat_timer.time_left
