extends Node

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal player_health_changed(current: int, max_hp: int)
signal special_meter_changed(current: float, max_meter: float)
signal combo_updated(hits: int, points: int)
signal stage_cleared()
signal game_over()
signal screen_shake_requested(intensity: float, duration: float)

var score: int = 0
var high_score: int = 25000
var lives: int = 3
var player_max_health: int = 100
var player_health: int = 100
var special_meter: float = 0.0
var max_special_meter: float = 100.0

var combo_hits: int = 0
var combo_points: int = 0
var combo_timer: float = 0.0
const COMBO_TIMEOUT: float = 2.4

var current_stage: int = 1
var is_touch_controls_enabled: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_inputs()
	# Auto-detect if mobile
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		is_touch_controls_enabled = true
	else:
		# On PC, enabled by default for testing, but can be toggled by player
		is_touch_controls_enabled = true

func _process(delta: float) -> void:
	if combo_hits > 0:
		combo_timer -= delta
		if combo_timer <= 0.0:
			_resolve_combo()

func _setup_inputs() -> void:
	_register_key_action("move_left", [KEY_LEFT, KEY_A], [JOY_BUTTON_DPAD_LEFT], JOY_AXIS_LEFT_X, -1.0)
	_register_key_action("move_right", [KEY_RIGHT, KEY_D], [JOY_BUTTON_DPAD_RIGHT], JOY_AXIS_LEFT_X, 1.0)
	_register_key_action("move_up", [KEY_UP, KEY_W], [JOY_BUTTON_DPAD_UP], JOY_AXIS_LEFT_Y, -1.0)
	_register_key_action("move_down", [KEY_DOWN, KEY_S], [JOY_BUTTON_DPAD_DOWN], JOY_AXIS_LEFT_Y, 1.0)
	
	# Attack (Jab / Combo / Kick)
	_register_key_action("attack", [KEY_J, KEY_Z, KEY_F, KEY_ENTER, KEY_KP_ENTER, KEY_SPACE], [JOY_BUTTON_X, JOY_BUTTON_B, JOY_BUTTON_A])
	# Jump
	_register_key_action("jump", [KEY_K, KEY_SPACE, KEY_X, KEY_W, KEY_UP], [JOY_BUTTON_A])
	# Blitz (Rush Strike)
	_register_key_action("blitz", [KEY_L, KEY_SHIFT, KEY_C], [JOY_BUTTON_RIGHT_SHOULDER, JOY_BUTTON_Y])
	# Special (Screen Blast)
	_register_key_action("special", [KEY_I, KEY_V, KEY_Q], [JOY_BUTTON_LEFT_SHOULDER])
	# Pause / Menu
	_register_key_action("pause", [KEY_ESCAPE, KEY_ENTER, KEY_KP_ENTER, KEY_P], [JOY_BUTTON_START, JOY_BUTTON_BACK])

func _register_key_action(action_name: String, keys: Array, buttons: Array = [], axis: JoyAxis = -1, axis_val: float = 0.0) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
		
	for key in keys:
		var ev := InputEventKey.new()
		ev.keycode = key
		ev.physical_keycode = key
		InputMap.action_add_event(action_name, ev)
		
	for btn in buttons:
		var ev := InputEventJoypadButton.new()
		ev.button_index = btn
		InputMap.action_add_event(action_name, ev)
		
	if axis >= 0:
		var ev := InputEventJoypadMotion.new()
		ev.axis = axis
		ev.axis_value = axis_val
		InputMap.action_add_event(action_name, ev)

func add_score(points: int) -> void:
	score += points
	if score > high_score:
		high_score = score
	score_changed.emit(score)

func add_hit(points: int = 100) -> void:
	combo_hits += 1
	var multiplier := 1.0 + float(combo_hits) * 0.15
	var awarded := int(float(points) * multiplier)
	combo_points += awarded
	combo_timer = COMBO_TIMEOUT
	add_score(awarded)
	add_special(4.0)
	combo_updated.emit(combo_hits, combo_points)

func _resolve_combo() -> void:
	if combo_hits >= 5:
		# Award bonus fanfare for high combos
		SoundManager.play("victory", 1.2)
	combo_hits = 0
	combo_points = 0
	combo_updated.emit(0, 0)

func add_special(amount: float) -> void:
	special_meter = clampf(special_meter + amount, 0.0, max_special_meter)
	special_meter_changed.emit(special_meter, max_special_meter)

func consume_special() -> bool:
	if special_meter >= max_special_meter:
		special_meter = 0.0
		special_meter_changed.emit(special_meter, max_special_meter)
		return true
	return false

func damage_player(amount: int) -> void:
	player_health = clampi(player_health - amount, 0, player_max_health)
	player_health_changed.emit(player_health, player_max_health)
	shake_screen(6.0, 0.2)
	if player_health <= 0:
		_player_lost_life()

func heal_player(amount: int) -> void:
	player_health = clampi(player_health + amount, 0, player_max_health)
	player_health_changed.emit(player_health, player_max_health)
	SoundManager.play("pickup")

func _player_lost_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()
	else:
		# Respawn with full health
		player_health = player_max_health
		player_health_changed.emit(player_health, player_max_health)

func hit_stop(duration: float = 0.08) -> void:
	# Streets of Rage 3 meaty hit freeze pause
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration * 0.05, true, false, true).timeout
	Engine.time_scale = 1.0

func shake_screen(intensity: float, duration: float) -> void:
	screen_shake_requested.emit(intensity, duration)

func reset_game() -> void:
	score = 0
	lives = 3
	player_health = player_max_health
	special_meter = 0.0
	combo_hits = 0
	current_stage = 1
