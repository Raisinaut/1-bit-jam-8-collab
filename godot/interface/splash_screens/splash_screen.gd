extends CanvasLayer

signal finished

@onready var text = %Text
@onready var container = $MarginContainer

@export var fade_duration : float = 0.6 # seconds
@export var pause_duration : float = 3.0 # seconds

enum DISPLAY_STATES{
	FADE_IN,
	PAUSE,
	FADE_OUT,
}
var state = -1 : set = set_state
var fade_tween : Tween
var skipped : bool = false


func _ready() -> void:
	state = DISPLAY_STATES.FADE_IN

func set_state(new_state) -> void:
	if state == new_state:
		return
	state = new_state
	match(state):
		DISPLAY_STATES.FADE_IN:
			container.modulate.a = 0.0
			await fade(1.0).finished
			set_state(DISPLAY_STATES.PAUSE)
		DISPLAY_STATES.PAUSE:
			fade_tween.kill()
			container.modulate.a = 1.0
			await pause().timeout
			set_state(DISPLAY_STATES.FADE_OUT)
		DISPLAY_STATES.FADE_OUT:
			container.modulate.a = 1.0
			await fade(0.0).finished
			finished.emit()

func fade(to_value : float, duration := fade_duration) -> Tween:
	if fade_tween: fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(container, "modulate:a", to_value, duration)
	return fade_tween

func pause():
	return get_tree().create_timer(pause_duration)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fire"):
		skip()

func skip() -> void:
	match(state):
		DISPLAY_STATES.FADE_IN:
			pass
		DISPLAY_STATES.PAUSE:
			state = DISPLAY_STATES.FADE_OUT
		DISPLAY_STATES.FADE_OUT:
			pass
