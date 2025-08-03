extends Control

@onready var panels = [
	$MainVBoxContainer,
	$Level1VBoxContainer,
	$Level2VBoxContainer
]

var current_panel_index = 0
var selected_index := 0

var is_muted := false
var just_muted := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	for i in range(panels.size()):
		panels[i].visible = i == current_panel_index
	selected_index = 0
	update_button_focus()

func _unhandled_input(event):
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
		selected_index = (selected_index + 1) % get_current_buttons().size()
		update_button_focus()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
		selected_index = (selected_index - 1) % get_current_buttons().size()
		update_button_focus()
	elif event.is_action_pressed("ui_accept"):
		press_selected_button()

func get_current_buttons():
	return panels[current_panel_index].get_children()

func update_button_focus():
	var buttons = get_current_buttons()
	for i in range(buttons.size()):
		buttons[i].focus_mode = Control.FOCUS_NONE
	var btn = buttons[selected_index]
	btn.focus_mode = Control.FOCUS_ALL
	btn.grab_focus()
	
	for button in get_current_buttons():
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func press_selected_button():
	var btn = get_current_buttons()[selected_index]
	btn.emit_signal("pressed")

func switch_panel(to_index):
	if to_index == current_panel_index:
		return
	panels[current_panel_index].visible = false
	current_panel_index = to_index
	panels[current_panel_index].visible = true
	selected_index = 0
	update_button_focus()

func _on_start_button_pressed():
	SceneManager.go_to_next_level = true
	SceneManager.goto_next_scene()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_level_1_button_pressed():
	SceneManager.go_to_next_level = false
	switch_panel(1)

func _on_level_2_button_pressed():
	SceneManager.go_to_next_level = false
	switch_panel(2)
	
func _on_back_button_pressed():
	switch_panel(0)

func _on_level_1a_button_pressed():
	SceneManager.goto_scene(SceneManager.scenes[1])

func _on_level_1b_button_pressed():
	SceneManager.goto_scene(SceneManager.scenes[2])

func _on_level_1c_button_pressed():
	SceneManager.goto_scene(SceneManager.scenes[3])

func _on_level_1d_button_pressed():
	SceneManager.goto_scene(SceneManager.scenes[4])

func _on_level_1e_button_pressed():
	SceneManager.goto_scene(SceneManager.scenes[5])

func _on_level_2a_button_pressed():
	SceneManager.goto_scene(SceneManager.scenes[6])

func _on_level_2b_button_pressed():
	SceneManager.goto_scene(SceneManager.scenes[7])
	
func _on_level_2c_button_pressed():
	SceneManager.goto_scene(SceneManager.scenes[8])

func _on_level_2d_button_pressed():
	SceneManager.goto_scene(SceneManager.scenes[9])

func _on_level_2e_button_pressed():
	SceneManager.goto_scene(SceneManager.scenes[10])

func _on_toggle_sound_button_pressed():
	if just_muted:
		just_muted = false
		return
	is_muted = !is_muted
	just_muted = true
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), is_muted)
