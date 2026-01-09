class_name AudioStreamPool
extends Node2D

@export var mono : bool = true
@export var audio_files : Array[AudioStream] = []
@export_range(0.00, 0.10, 0.01) var pitch_variance = 0.0
@export var initial_volume_db = -6.0
@export_range(-1, 1, 0.05) var pitch_offset := 0.0
@export var bus_name = ""
## The number of audio stream players in the pool
@export var pool_size = 4
@export var minimum_interval : float = 0.05 # seconds

var rng = RandomNumberGenerator.new()
var shuffle_bag_files : Array[AudioStream] = []
var pool_idx = 0
var interval_timer : SceneTreeTimer

func _ready():
	rng.randomize()
	_create_stream_players()

## Select a new player and selects a random stream
func play(at_position := Vector2.ZERO):
	if interval_timer and interval_timer.time_left != 0.0:
		return
	var random_stream = get_random_stream()
	if not mono:
		get_current_player().global_position = at_position
	get_current_player().stream = random_stream
	get_current_player().pitch_scale = get_varied_pitch()
	get_current_player().play()
	next_player()
	start_interval_timer()


func next_player():
	pool_idx = wrapi(pool_idx + 1, 0, get_child_count()-1)


func get_random_stream():
	if shuffle_bag_files.is_empty():
		shuffle_bag_files = audio_files.duplicate()
		if shuffle_bag_files.size() > 1:
			shuffle_bag_files.erase(get_current_player().stream)
		shuffle_bag_files.shuffle()
	return shuffle_bag_files.pop_back()


func _create_stream_players():
	for i in pool_size:
		var player_type = AudioStreamPlayer if mono else AudioStreamPlayer2D
		var p = player_type.new()
		p.volume_db = initial_volume_db
		p.bus = bus_name
		call_deferred("add_child", p)

func get_varied_pitch():
	return 1 + pitch_offset + rng.randf_range(-pitch_variance, pitch_variance)

func get_current_player():
	return get_child(pool_idx)

func start_interval_timer():
	interval_timer = get_tree().create_timer(minimum_interval, false)
