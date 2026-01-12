extends CanvasLayer

@onready var glitch = $Glitch
@onready var invert = $Invert

var glitch_enabled : bool = false : set = set_glitch_enabled
var invert_enabled : bool = false : set = set_invert_enabled


func _ready() -> void:
	glitch_enabled = false
	invert_enabled = false

func set_glitch_enabled(state : bool) -> void:
	glitch_enabled = state
	glitch.visible = glitch_enabled

func set_invert_enabled(state : bool) -> void:
	invert_enabled = state
	invert.visible = invert_enabled
