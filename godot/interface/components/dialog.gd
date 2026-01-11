extends CenterContainer

@onready var btn_descend = $PanelContainer/MarginContainer/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/BtnDescend
@onready var btn_stay = $PanelContainer/MarginContainer/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/BtnStay

func _ready() -> void:
	GameManager.player.moved_exit.connect(show)
	btn_descend.pressed.connect(GameManager.level.load_next_level)
	btn_stay.pressed.connect(hide)
