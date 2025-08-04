extends Control

@onready var panels = [
	$Main,
	$Levels
]

var panel_buttons = []

var current_panel_index := 0
var selected_index := 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	for panel in panels:
		var buttons = []
		get_buttons_recursive(panel, buttons)
		panel_buttons.append(buttons)
	
	show_panel(0)
	update_button_focus()

func get_buttons_recursive(node: Node, buttons: Array):
	for child in node.get_children():
		if child is Button:
			buttons.append(child)
		elif child.get_child_count() > 0:
			get_buttons_recursive(child, buttons)

func _unhandled_input(event):
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
		move_selection(1)
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
		move_selection(-1)
	elif event.is_action_pressed("ui_accept"):
		_press_selected_button()

func move_selection(delta: int):
	var buttons = panel_buttons[current_panel_index]
	selected_index = (selected_index + delta) % buttons.size()
	update_button_focus()

func update_button_focus():
	var buttons = panel_buttons[current_panel_index]
	for btn in buttons:
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var btn = buttons[selected_index]
	btn.focus_mode = Control.FOCUS_ALL
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.grab_focus()

func _press_selected_button():
	var btn = panel_buttons[current_panel_index][selected_index]
	btn.emit_signal("pressed")

func show_panel(index: int):
	for i in range(panels.size()):
		panels[i].visible = i == index
	current_panel_index = index
	selected_index = 0
	update_button_focus()

func _on_start_button_pressed():
	SceneManager.load_next_level = true
	SceneManager.load_next_scene()

func _on_levels_button_pressed():
	SceneManager.load_next_level = false
	show_panel(1)

func _on_sound_button_toggled(toggled_on: bool):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), toggled_on)
	
func _on_quit_button_pressed():
	get_tree().quit()

func _on_back_button_pressed():
	show_panel(0)

func _on_1a_button_pressed():
	SceneManager.load_scene(1)

func _on_1b_button_pressed():
	SceneManager.load_scene(2)

func _on_1c_button_pressed():
	SceneManager.load_scene(3)

func _on_1d_button_pressed():
	SceneManager.load_scene(4)

func _on_1e_button_pressed():
	SceneManager.load_scene(5)

func _on_2a_button_pressed():
	SceneManager.load_scene(6)

func _on_2b_button_pressed():
	SceneManager.load_scene(7)
	
func _on_2c_button_pressed():
	SceneManager.load_scene(8)

func _on_2d_button_pressed():
	SceneManager.load_scene(9)

func _on_2e_button_pressed():
	SceneManager.load_scene(10)
