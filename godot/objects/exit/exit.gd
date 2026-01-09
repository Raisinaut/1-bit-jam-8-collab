extends GridObject

@onready var sprite = $Sprite2D
@onready var sprite_fill = $Sprite2D/SpriteFill
@onready var shaker = $Shaker
@onready var detection = $Detection
@onready var visibility_timer = $VisibilityTimer

var fade_time: float = 4.0 # seconds

func _ready() -> void:
	visibility_timer.wait_time = fade_time
	visibility_timer.one_shot = true
	detection.area_entered.connect(_on_detection_area_entered)
	sprite_fill.hide()

func _process(_delta: float) -> void:
	var fade_value = get_fade_progress_value()
	sprite.scale = Vector2.ONE * lerp(0.0, 1.0, get_fade_progress_value())
	sprite.visible = fade_value > 0.0
	#sprite_fill.scale = Vector2.ONE * lerp(1.0, 0.8, get_fade_progress_value())
	#sprite_fill.offset = sprite.offset
	

func shake() -> void:
	shaker.start()

func _on_detection_area_entered(area : Area2D) -> void:
	area.queue_free()
	illuminate()

func illuminate() -> void:
	shake()
	reset_visibility_timer()

func reset_visibility_timer() -> void:
	visibility_timer.start()

func get_fade_progress_value() -> float:
	return visibility_timer.time_left / visibility_timer.wait_time
