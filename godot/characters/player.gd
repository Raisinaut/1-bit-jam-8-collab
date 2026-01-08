extends GridCharacter


var movement_timer : SceneTreeTimer

func _ready() -> void:
	GameManager.player = self

func _process(_delta: float) -> void:
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	if direction:
		attempt_move(direction)
