extends Node

@export var action_name : String = "screenshot"
@export var confirm_before_saving := true

@onready var save_dialog : FileDialog = $SaveDialog
@onready var preview_interface = $PreviewInterface

@onready var last_pause_state = get_tree().paused

var latest_shot : Image = null


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	close_dialog()
	setup_dialog()
	preview_interface.screenshot_confirmed.connect(open_dialog)
	preview_interface.screenshot_canceled.connect(close_dialog)
	add_screenshot_action()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if Input.is_action_just_pressed(action_name):
		if not is_processing_screenshot():
			state_safe_pause()
			latest_shot = await get_viewport_image()
			
			if confirm_before_saving:
				preview_interface.open()
			else:
				open_dialog()

func add_screenshot_action():
	if InputMap.has_action(action_name):
		return
	InputMap.add_action(action_name)
	var event = InputEventKey.new()
	event.keycode = KEY_F11
	InputMap.action_add_event(action_name, event)


# Screenshot Management -------------------------------------------------------#

func save_screenshot(directory : String, filename):
	if not OS.is_debug_build() : return
	
	await RenderingServer.frame_post_draw
	var image = get_latest_shot(false)
	var error = image.save_png(directory + "/" + filename)
	
	if error == OK:
		print("Screenshot saved to ", directory)
		OS.shell_show_in_file_manager(directory)
	else:
		printerr("Did not save screenshot to ", directory)

func get_viewport_image() -> Image:
	await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image()

func get_latest_shot(as_texture : bool) -> Resource:
	if !latest_shot:
		return null
	
	if as_texture:
		return ImageTexture.create_from_image(latest_shot)
	else:
		return latest_shot


# Dialog ----------------------------------------------------------------------#

func setup_dialog():
	var x = ProjectSettings.get("display/window/size/viewport_width")
	var y = ProjectSettings.get("display/window/size/viewport_height")
	save_dialog.max_size = Vector2(x, y) * 0.8
	
	save_dialog.add_button("Generate Filename", true, "generate_filename")
	save_dialog.confirmed.connect(_on_save_dialog_confirmed)
	save_dialog.visibility_changed.connect(_on_save_dialog_visibility_changed)
	save_dialog.custom_action.connect(_on_save_dialog_custom_action)

func open_dialog():
	save_dialog.show()

func close_dialog():
	save_dialog.hide()
	state_safe_unpause()

func _on_save_dialog_confirmed() -> void:
	close_dialog()
	save_screenshot(save_dialog.current_dir, save_dialog.get_line_edit().text)

func _on_save_dialog_visibility_changed() -> void:
	if not save_dialog.visible:
		close_dialog()

func _on_save_dialog_custom_action(action : String) -> void:
	match action:
		"generate_filename":
			save_dialog.get_line_edit().text = generate_default_filename()

func generate_default_filename() -> String:
	var date = Time.get_date_string_from_system().replace(".","_") 
	var time :String = Time.get_time_string_from_system().replace(":","")
	var project = ProjectSettings.get("application/config/name")
	var filename = project + " " + date + " " + time + ".jpg"
	return filename


# Pausing ---------------------------------------------------------------------#

func state_safe_pause():
	last_pause_state = get_tree().paused
	get_tree().paused = true

func state_safe_unpause():
	get_tree().paused = last_pause_state


# Checks ----------------------------------------------------------------------#

func is_processing_screenshot() -> bool:
	return save_dialog.visible or preview_interface.visible
