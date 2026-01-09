extends Node

@onready var ambience = $Ambience

func _ready() -> void:
	ambience.play()
