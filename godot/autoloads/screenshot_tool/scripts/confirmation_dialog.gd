extends MarginContainer

signal confirmed
signal canceled
signal close_requested

@onready var cancel = $HBoxContainer/cancel
@onready var confirm = $HBoxContainer/confirm


func _ready() -> void:
	cancel.pressed.connect(_on_cancel_pressed)
	confirm.pressed.connect(_on_confirm_pressed)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close_requested.emit()

func _on_cancel_pressed():
	canceled.emit()
	hide()

func _on_confirm_pressed():
	confirmed.emit()
	hide()
