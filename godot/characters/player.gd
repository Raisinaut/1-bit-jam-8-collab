class_name Player
extends GridCharacter

signal touched_ghost

@onready var footsteps = $Footsteps
@onready var ghost_detection = $GhostDetection

var movement_timer : SceneTreeTimer


func _ready() -> void:
	GameManager.player = self
	move_cooldown = 0.1
	moved.connect(_on_moved)
	bonked.connect(_on_bonked)
	ghost_detection.area_entered.connect(_on_ghost_detection_area_entered)
	
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

func _on_ghost_detection_area_entered(_area : Area2D) -> void:
	touched_ghost.emit()
