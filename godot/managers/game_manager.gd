extends Node

var player : Node2D = null
var grid_node : GridNode = null
var camera : ShakyCamera = null : set = set_camera
var gun = null

func set_camera(node) -> void:
	camera = node
	camera.target = player
	camera.global_position = player.global_position
