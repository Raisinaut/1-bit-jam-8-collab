class_name Ghost
extends Area2D

var MIN_RECOVERY_TIME : float = 3 # seconds
var MAX_RECOVERY_TIME : float = 5 # seconds

@onready var sprite : Sprite2D = $Sprite2D
@onready var stun_timer : Timer = $StunTimer
@onready var shaker = $Shaker
@onready var border_positioner = $BorderPositioner

@onready var static_sfx = $StaticSFX
@onready var stunned_sfx = $StunnedSFX

var move_speed : float = 150
var stun_duration : float = 1.5 # seconds
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

func _on_area_entered(area : Area2D) -> void:
	if state == STATES.CHASE:
		if area is Projectile:
			state = STATES.STUNNED
			area.queue_free()

func set_state(new_state : STATES) -> void:
	state = new_state
	print("Ghost state: ", STATES.find_key(state))
	match(state):
		STATES.CHASE:
			hide()
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
			global_position = Vector2.ONE * 200000 # go faaaar away
			stunned_sfx.stop()
			start_recovery_timer()
		STATES.DESTROYED:
			destroy()

func teleport_to_view_edge() -> void:
	global_position = border_positioner.get_random_border_position()

func start_recovery_timer():
	var recovery_time = randf_range(MIN_RECOVERY_TIME, MAX_RECOVERY_TIME)
	var recovery_timer = get_tree().create_timer(recovery_time)
	recovery_timer.timeout.connect(_on_recovery_timer_timeout)

func destroy() -> void:
	queue_free()

# SIGNALS ----------------------------------------------------------------------
func _on_stun_timer_timeout() -> void:
	sprite.active = false
	if destoy_after_stun:
		state = STATES.DESTROYED
	else:
		state = STATES.RECOVER

func _on_recovery_timer_timeout() -> void:
	teleport_to_view_edge()
	state = STATES.CHASE
