class_name Ghost
extends Area2D

var MAX_SPEED : float = 300
var MIN_SPEED : float = 150
var ACCELERATION : float = 20
var MIN_RECOVERY_TIME : float = 4 # seconds
var MAX_RECOVERY_TIME : float = 6 # seconds

@onready var sprite : Sprite2D = $Sprite2D
@onready var stun_timer : Timer = $StunTimer
@onready var shaker = $Shaker
@onready var stats = $Stats
@onready var hurtbox = $HurtBox
@onready var visibility_flasher = $VisibilityFlasher

@onready var static_sfx = $StaticSFX
@onready var harsh_static_sfx = $HarshStaticSFX
@onready var stunned_sfx = $StunnedSFX
@onready var scream_sfx = $ScreamSFX

var move_speed : float = 150
var stun_duration : float = 1.0 # seconds
var stunned : bool = false
var flash_duration : float = 0.12
var flash_timer : SceneTreeTimer

enum STATES{CHASE, DESTROYED}
var state = STATES.CHASE : set = set_state


func _ready() -> void:
	state = state
	stats.hp_depleted.connect(_on_stats_hp_depleted)
	stun_timer.timeout.connect(_on_stun_timer_timeout)
	stun_timer.one_shot = true
	scream_sfx.process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	match(state):
		STATES.CHASE:
			follow_player(delta)
			increase_move_speed(delta)
		STATES.DESTROYED:
			shaker.start(0.2, 30, 50)

func follow_player(delta: float) -> void:
	var player = GameManager.player
	if player:
		var move_direction = global_position.direction_to(player.global_position)
		global_position += move_direction * move_speed * delta

func increase_move_speed(delta: float) -> void:
	move_speed += ACCELERATION * delta
	move_speed = min(move_speed, MAX_SPEED)

func dampen_move_speed() -> void:
	move_speed = max(move_speed * 0.75, MIN_SPEED)

func reset_move_speed() -> void:
	move_speed = MIN_SPEED

func set_state(new_state : STATES) -> void:
	state = new_state
	#print("Ghost state: ", STATES.find_key(state))
	match(state):
		STATES.CHASE:
			hide()
			static_sfx.play()
			set_deferred("monitorable", true)
		STATES.DESTROYED:
			show()
			stunned_sfx.play_random()
			static_sfx.stop()
			set_deferred("monitorable", false)
			sprite.active = true
			stun_timer.start(stun_duration)

func take_damage(amount : int) -> void:
	stats.hp -= amount
	dampen_move_speed()
	if stats.hp > 0:
		flash()

func flash() -> void:
	show()
	
	# play hit sfx
	harsh_static_sfx.play_random()
	flash_timer = get_tree().create_timer(flash_duration)
	
	# flash sprite
	visibility_flasher.active = true
	await flash_timer.timeout
	visibility_flasher.active = false
	
	# stop hit sfx
	harsh_static_sfx.stop()
	if state == STATES.CHASE:
		hide()

func scream() -> void:
	show()
	scream_sfx.play_random()

func destroy() -> void:
	queue_free()

# SIGNALS ----------------------------------------------------------------------
func _on_stats_hp_depleted() -> void:
	state = STATES.DESTROYED

func _on_stun_timer_timeout() -> void:
	queue_free()

func _on_recovery_timer_timeout() -> void:
	state = STATES.CHASE
