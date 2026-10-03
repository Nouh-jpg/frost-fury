extends CanvasLayer

# Android On-Screen Virtual Controller
# Emits real Godot Input actions so gamepad, keyboard, and touch work seamlessly!

@onready var dpad_area: Control = $LeftPad/DpadArea
@onready var btn_attack: TouchScreenButton = $RightPad/BtnAttack
@onready var btn_jump: TouchScreenButton = $RightPad/BtnJump
@onready var btn_blitz: TouchScreenButton = $RightPad/BtnBlitz
@onready var btn_special: TouchScreenButton = $RightPad/BtnSpecial

var dpad_touch_idx: int = -1
var dpad_center: Vector2 = Vector2.ZERO
var dpad_radius: float = 48.0

func _ready() -> void:
	visible = GameManager.is_touch_controls_enabled
	dpad_center = dpad_area.size * 0.5

func _input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event is InputEventScreenTouch:
		var local_pos = dpad_area.get_local_mouse_position()
		if event.pressed and local_pos.length_squared() < pow(dpad_radius * 1.5, 2):
			dpad_touch_idx = event.index
			_update_dpad(local_pos)
		elif not event.pressed and event.index == dpad_touch_idx:
			dpad_touch_idx = -1
			_release_dpad_actions()
			
	elif event is InputEventScreenDrag and event.index == dpad_touch_idx:
		var local_pos = dpad_area.get_local_mouse_position()
		_update_dpad(local_pos)

func _update_dpad(pos: Vector2) -> void:
	var diff := pos - dpad_center
	var deadzone := 12.0
	
	if diff.x < -deadzone:
		Input.action_press("move_left")
		Input.action_release("move_right")
	elif diff.x > deadzone:
		Input.action_press("move_right")
		Input.action_release("move_left")
	else:
		Input.action_release("move_left")
		Input.action_release("move_right")
		
	if diff.y < -deadzone:
		Input.action_press("move_up")
		Input.action_release("move_down")
	elif diff.y > deadzone:
		Input.action_press("move_down")
		Input.action_release("move_up")
	else:
		Input.action_release("move_up")
		Input.action_release("move_down")

func _release_dpad_actions() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("move_up")
	Input.action_release("move_down")
