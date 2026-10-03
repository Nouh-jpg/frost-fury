extends Control

@onready var prompt_label: Label = $VBox/PressStartPrompt
@onready var help_panel: PanelContainer = $HelpPanel
@onready var how_to_play_btn: Button = $VBox/ButtonContainer/HowToPlayButton
@onready var start_btn: Button = $VBox/ButtonContainer/StartButton

var blink_timer: float = 0.0

func _ready() -> void:
	help_panel.visible = false
	start_btn.pressed.connect(_start_game)
	how_to_play_btn.pressed.connect(_toggle_help)
	$HelpPanel/VBox/CloseHelpButton.pressed.connect(func(): help_panel.visible = false)

func _process(delta: float) -> void:
	blink_timer += delta * 3.5
	prompt_label.modulate.a = 0.5 + 0.5 * sin(blink_timer)
	
	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("attack"):
		if not help_panel.visible:
			_start_game()
		else:
			help_panel.visible = false

func _start_game() -> void:
	SoundManager.play("victory", 1.0)
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _toggle_help() -> void:
	help_panel.visible = not help_panel.visible
	SoundManager.play("punch", 1.5)
