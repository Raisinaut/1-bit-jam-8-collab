@tool

class_name IncrementProgressBar
extends PanelContainer

@export_range(1, 50) var increment_count : int = 10 : set = set_increment_count
@export var increment_color : Color = Color.WHITE
@export_range(1, 16) var separation : int = 8 : set = set_separation
@export_range(1, 1000) var length : int = 200 : set = set_length

# TODO : Not using for this project, but it would need ability to change progress

func refresh_increments() -> void:
	$VBoxContainer.add_theme_constant_override("separation", separation)
	delete_increments()
	for i in increment_count:
		var increment = add_increment()
		if i == increment_count-1:
			await increment.ready

func add_increment() -> ColorRect:
	var increment = ColorRect.new()
	var total_separation = (increment_count - 1) * separation
	var total_height = length - total_separation
	var increment_height = total_height / increment_count
	#var increment_height = 32
	increment.custom_minimum_size.x = 32
	increment.custom_minimum_size.y = increment_height
	$VBoxContainer.add_child(increment)
	increment.owner = get_tree().edited_scene_root
	return increment

func delete_increments() -> void:
	for i in $VBoxContainer.get_children():
		i.queue_free()

func set_increment_count(value : int) -> void:
	increment_count = value
	refresh_increments()

func set_separation(value : int) -> void:
	separation = value
	refresh_increments()

func set_length(value : int) -> void:
	length = value
	refresh_increments()
