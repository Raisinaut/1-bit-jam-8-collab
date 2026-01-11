extends CenterContainer

@onready var btn_descend = $PanelContainer/MarginContainer/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/BtnDescend
@onready var btn_stay = $PanelContainer/MarginContainer/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/BtnStay

func _ready() -> void:
	GameManager.player.moved_exit.connect(show_dialog)
	btn_descend.pressed.connect(_on_btn_descend_pressed)
	btn_stay.pressed.connect(hide_dialog)

func show_dialog() -> void:
	show()
	get_tree().paused = true

func hide_dialog() -> void:
	hide()
	get_tree().paused = false

func _on_btn_descend_pressed() -> void:
	GameManager.level.load_next_level()
	get_tree().paused = false
