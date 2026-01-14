extends CanvasLayer

signal screenshot_confirmed
signal screenshot_canceled

@onready var preview : TextureRect = $Control/Preview
@onready var flash : ColorRect = $Control/Flash
@onready var confirmation := $Control/ConfirmationDialog
@onready var shadow = $Control/Shadow


var flash_tween : Tween = null


func _ready() -> void:
	close()
	confirmation.confirmed.connect(_on_confirmed)
	confirmation.canceled.connect(_on_canceled)
	confirmation.close_requested.connect(_on_canceled)

func start_flash(duration := 0.5):
	flash.color.a = 0.5
	
	if flash_tween:
		flash_tween.kill()
	flash_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	flash_tween.tween_property(flash, "color:a", 0.0, duration)


func open():
	start_flash()
	preview.texture = get_parent().get_latest_shot(true)
	confirmation.show()
	shadow.show()
	show()

func close():
	confirmation.hide()
	shadow.hide()
	hide()


func _on_confirmed():
	screenshot_confirmed.emit()
	close()

func _on_canceled():
	screenshot_canceled.emit()
	close()
