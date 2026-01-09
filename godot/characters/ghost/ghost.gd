class_name Ghost
extends Area2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var stun_timer : Timer = $StunTimer
@onready var shaker = $Shaker

@export var death_effect : PackedScene

var move_speed : float = 150
var stun_duration : float = 2.0 # seconds
var stunned : bool = false
var destoy_after_stun : bool = false

enum STATES{CHASE, STUNNED, DESTROYED}
var state = STATES.CHASE : set = set_state


func _ready() -> void:
	state = state
	area_entered.connect(_on_area_entered)
	stun_timer.timeout.connect(_on_stun_timer_timeout)

func _process(delta: float) -> void:
	match(state):
		STATES.CHASE:
			follow_player(delta)
		STATES.STUNNED:
			shaker.start(0.2, 30, 50)
		STATES.DESTROYED:
			pass

func follow_player(delta: float) -> void:
	var player = GameManager.player
	if player:
		var move_direction = global_position.direction_to(player.global_position)
		global_position += move_direction * move_speed * delta

func _on_area_entered(area : Area2D) -> void:
	if area is Projectile:
		state = STATES.STUNNED

func set_state(new_state : STATES) -> void:
	state = new_state
	match(state):
		STATES.CHASE:
			start_chase()
		STATES.STUNNED:
			stun()
		STATES.DESTROYED:
			destroy()

func start_chase():
	hide()
	set_deferred("monitorable", true)

func stun() -> void:
	show()
	set_deferred("monitorable", false)
	sprite.active = true
	stun_timer.start(stun_duration)

func _on_stun_timer_timeout() -> void:
	sprite.active = false
	if destoy_after_stun:
		state = STATES.DESTROYED
	else:
		state = STATES.CHASE

func destroy() -> void:
	queue_free()
