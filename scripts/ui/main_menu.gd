extends Control

@onready var prompt_label: Label = $VBox/PressStartPrompt
@onready var help_panel: PanelContainer = $HelpPanel
@onready var how_to_play_btn: Button = $VBox/ButtonContainer/HowToPlayButton
@onready var start_btn: Button = $VBox/ButtonContainer/StartButton

var blink_timer: float = 0.0
var starting: bool = false

func _ready() -> void:
	starting = false
	help_panel.visible = false
	start_btn.pressed.connect(_on_start_pressed)
	how_to_play_btn.pressed.connect(_toggle_help)
	$HelpPanel/VBox/CloseHelpButton.pressed.connect(func(): 
		help_panel.visible = false
		start_btn.grab_focus()
	)
	
	# Focus start button for immediate keyboard/gamepad navigation
	start_btn.grab_focus()

func _process(delta: float) -> void:
	blink_timer += delta * 3.5
	prompt_label.modulate.a = 0.4 + 0.6 * abs(sin(blink_timer))

func _gui_input(event: InputEvent) -> void:
	# Clicking anywhere on the background / screen
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_general_activation()
	elif event is InputEventScreenTouch and event.pressed:
		_handle_general_activation()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE and help_panel.visible:
			help_panel.visible = false
			start_btn.grab_focus()
			get_viewport().set_input_as_handled()
			return
		_handle_general_activation()
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.pressed:
		_handle_general_activation()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_general_activation()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		_handle_general_activation()
		get_viewport().set_input_as_handled()

func _handle_general_activation() -> void:
	if help_panel.visible:
		help_panel.visible = false
		start_btn.grab_focus()
		SoundManager.play("punch", 1.2)
		return
	_start_game()

func _on_start_pressed() -> void:
	_start_game()

func _start_game() -> void:
	if starting:
		return
	starting = true
	SoundManager.play("victory", 1.0)
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _toggle_help() -> void:
	help_panel.visible = not help_panel.visible
	if help_panel.visible:
		$HelpPanel/VBox/CloseHelpButton.grab_focus()
	else:
		start_btn.grab_focus()
	SoundManager.play("punch", 1.4)
