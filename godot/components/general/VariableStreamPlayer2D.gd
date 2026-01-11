@tool
class_name VariableStreamPlayer2D
extends AudioStreamPlayer2D

@export var test_randomize : bool = false : set = set_test_randomize
@export var audio_files : Array[AudioStream] = []
@export_range(0.00, 0.10, 0.01) var pitch_variance = 0.0
@export var base_pitch = 1.0

var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()

func play_random():
	randomize_stream()
	play()

func randomize_stream():
	if not audio_files.is_empty():
		var random_index: = rng.randi() % audio_files.size()
		stream = audio_files[random_index]
	pitch_scale = base_pitch + rng.randf_range(-pitch_variance, pitch_variance)

func choose_random_pitch():
	pitch_scale = base_pitch + rng.randf_range(-pitch_variance, pitch_variance)

func set_test_randomize(state : bool):
	if not Engine.is_editor_hint():
		return
	test_randomize = state
	if test_randomize:
		test_randomize = false 
		randomize_stream()
		play()
