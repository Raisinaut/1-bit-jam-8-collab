class_name Ghost
extends Area2D

var MAX_SPEED : float = 300
var MIN_SPEED : float = 150
var ACCELERATION : float = 10
var MIN_RECOVERY_TIME : float = 4 # seconds
var MAX_RECOVERY_TIME : float = 6 # seconds

@onready var sprite : Sprite2D = $Sprite2D
@onready var stun_timer : Timer = $StunTimer
@onready var shaker = $Shaker
@onready var border_positioner = $BorderPositioner

@onready var static_sfx = $StaticSFX
@onready var stunned_sfx = $StunnedSFX

var move_speed : float = 150
var stun_duration : float = 1.0 # seconds
var stunned : bool = false
var destoy_after_stun : bool = false

enum STATES{CHASE, STUNNED, RECOVER, DESTROYED}
var state = STATES.CHASE : set = set_state


func _ready() -> void:
	state = state
	area_entered.connect(_on_area_entered)
	stun_timer.timeout.connect(_on_stun_timer_timeout)
	stun_timer.one_shot = true

func _process(delta: float) -> void:
	match(state):
		STATES.CHASE:
			follow_player(delta)
			increase_move_speed(delta)
		STATES.STUNNED:
			shaker.start(0.2, 30, 50)
		STATES.RECOVER:
			pass
		STATES.DESTROYED:
			pass

func follow_player(delta: float) -> void:
	var player = GameManager.player
	if player:
		var move_direction = global_position.direction_to(player.global_position)
		global_position += move_direction * move_speed * delta

func increase_move_speed(delta: float) -> void:
	move_speed += ACCELERATION * delta
	move_speed = min(move_speed, MAX_SPEED)

func reset_move_speed() -> void:
	move_speed = MIN_SPEED

func set_state(new_state : STATES) -> void:
	state = new_state
	#print("Ghost state: ", STATES.find_key(state))
	match(state):
		STATES.CHASE:
			hide()
			teleport_to_view_edge()
			static_sfx.play()
			set_deferred("monitorable", true)
		STATES.STUNNED:
			show()
			stunned_sfx.play()
			static_sfx.stop()
			set_deferred("monitorable", false)
			sprite.active = true
			stun_timer.start(stun_duration)
		STATES.RECOVER:
			hide()
			teleport_far_away()
			reset_move_speed()
			stunned_sfx.stop()
			start_recovery_timer()
		STATES.DESTROYED:
			destroy()

func teleport_far_away() -> void:
	global_position = Vector2.ONE * 200000

func teleport_to_view_edge() -> void:
	global_position = await border_positioner.get_random_border_position()

func start_recovery_timer():
	var recovery_time = randf_range(MIN_RECOVERY_TIME, MAX_RECOVERY_TIME)
	var recovery_timer = get_tree().create_timer(recovery_time)
	recovery_timer.timeout.connect(_on_recovery_timer_timeout)

func destroy() -> void:
	queue_free()

# SIGNALS ----------------------------------------------------------------------
func _on_area_entered(area : Area2D) -> void:
	if state == STATES.CHASE:
		if area is Projectile:
			state = STATES.STUNNED
			area.queue_free()


func _on_stun_timer_timeout() -> void:
	sprite.active = false
	if destoy_after_stun:
		state = STATES.DESTROYED
	else:
		state = STATES.RECOVER

func _on_recovery_timer_timeout() -> void:
	state = STATES.CHASE
