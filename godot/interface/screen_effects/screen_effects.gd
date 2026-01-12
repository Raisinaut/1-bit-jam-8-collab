extends CanvasLayer

@onready var glitch = $Glitch

var glitch_enabled : bool = false : set = set_glitch_enabled


func _ready() -> void:
	glitch_enabled = false

func set_glitch_enabled(state : bool) -> void:
	glitch_enabled = state
	glitch.visible = glitch_enabled
