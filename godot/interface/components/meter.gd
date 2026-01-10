extends PanelContainer

@onready var progress_bar = %ProgressBar

var progress : float = 0.0 : set = set_progress

func set_progress(value : float) -> void:
	value = clamp(value, progress_bar.min_value, progress_bar.max_value)
	progress = value
	progress_bar.value = progress
