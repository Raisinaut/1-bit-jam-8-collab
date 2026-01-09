extends GridCharacter

@onready var footsteps = $Footsteps

var movement_timer : SceneTreeTimer


func _ready() -> void:
	GameManager.player = self
	moved.connect(_on_moved)
	bonked.connect(_on_bonked)
	move_cooldown = 0.1

func _process(_delta: float) -> void:
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	if direction:
		attempt_move(direction)

func _on_moved() -> void:
	footsteps.play()

func _on_bonked() -> void:
	# play bonk sfx
	pass
