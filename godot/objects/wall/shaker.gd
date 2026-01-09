extends Node

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

@export var shake_target : Node2D
@onready var frequency_timer := $FrequencyTimer
@onready var duration_timer := $DurationTimer

var amplitude = 0
var priority = 0
var alternate_shake_direction = false
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	frequency_timer.timeout.connect(_on_frequency_timeout)
	duration_timer.timeout.connect(_on_duration_timeout)
	duration_timer.one_shot = true

func start(duration := 0.2, frequency : int = 15, new_amplitude : int = 16, new_priority : int = 0):
	if (new_priority >= self.priority):
		self.priority = new_priority
		self.amplitude = new_amplitude
		
		duration_timer.start(duration)
		frequency_timer.start(1 / float(frequency))
		
		_new_shake()

func _new_shake():
	var shake_vec = Vector2()
	var tween = create_tween()
	var dampen = remap(duration_timer.time_left, 0, duration_timer.wait_time, 0, 1)
	
	shake_vec.x = rng.randf_range(-amplitude, amplitude)
	shake_vec.y = rng.randf_range(-amplitude, amplitude)
	shake_vec *= dampen
	# swap directions for every shake
	if alternate_shake_direction:
		shake_vec.x *= -1
	
	tween.set_trans(TRANS)
	tween.set_ease(EASE)
	tween.tween_property(shake_target, "offset", shake_vec, frequency_timer.wait_time)
	
	alternate_shake_direction = true

# restore offset
func _reset():
	var tween = create_tween()
	tween.tween_property(shake_target, "offset", Vector2.ZERO, frequency_timer.wait_time)
	priority = 0

# continue shaking
func _on_frequency_timeout():
	_new_shake()
# end shaking
func _on_duration_timeout():
	_reset()
	frequency_timer.stop()

func is_shaking() -> bool:
	return frequency_timer.time_left > 0
