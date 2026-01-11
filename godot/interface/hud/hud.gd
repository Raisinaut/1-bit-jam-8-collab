extends CanvasLayer

@onready var dialog = $Dialog
@onready var overheat_meter = %OverheatMeter
@onready var visibility_flasher = $VisibilityFlasher
@onready var flash_sfx = $FlashSFX

func _ready() -> void:
	visibility_flasher.linked_node = overheat_meter
	visibility_flasher.flashed.connect(_on_visibility_flasher_flashed)
	GameManager.gun.overheat_amount_changed.connect(_on_gun_overheat_amount_changed)
	GameManager.gun.overheat_started.connect(_on_gun_overheat_started)
	GameManager.gun.overheat_ended.connect(_on_gun_overheat_ended)


# SIGNALS ----------------------------------------------------------------------
func _on_gun_overheat_amount_changed(amount : float) -> void:
	overheat_meter.set_progress(amount)

func _on_gun_overheat_started() -> void:
	visibility_flasher.active = true

func _on_gun_overheat_ended() -> void:
	visibility_flasher.active = false

func _on_visibility_flasher_flashed() -> void:
	flash_sfx.play()
