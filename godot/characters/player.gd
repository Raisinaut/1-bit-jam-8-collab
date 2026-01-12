class_name Player
extends GridCharacter

signal touched_ghost

@onready var footsteps = $Footsteps
@onready var ghost_detection = $GhostDetection

var movement_timer : SceneTreeTimer

var last_x = 0
var last_y = 0

enum Axis { X, Y, NONE }
var last_axis = Axis.NONE

func _ready() -> void:
	GameManager.player = self
	move_cooldown = 0.1
	moved.connect(_on_moved)
	bonked.connect(_on_bonked)
	ghost_detection.area_entered.connect(_on_ghost_detection_area_entered)

func _process(_delta: float) -> void:
	var x = Input.get_axis("move_left", "move_right")
	var y = Input.get_axis("move_up", "move_down")
	
	var direction = get_move_vector(x,y)
	if direction.x != 0:   last_axis = Axis.X
	elif direction.y != 0: last_axis = Axis.Y
	else: last_axis = Axis.NONE

	last_x = x
	last_y = y
	
	attempt_move(direction)

func get_move_vector(x: float, y: float) -> Vector2:
	if x != 0 and y != 0:
		#print(x," ",y)
		if last_x == 0:   return Vector2(x, 0)
		elif last_y == 0: return Vector2(0, y)
		else:
			if last_axis == Axis.X: return Vector2(x, 0)
			if last_axis == Axis.Y: return Vector2(0, y)
	
	return Vector2(x,y)


func _on_moved() -> void:
	footsteps.play()

func _on_bonked() -> void:
	# play bonk sfx
	pass

func _on_ghost_detection_area_entered(ghost : Ghost) -> void:
	ghost.scream()
	touched_ghost.emit()
