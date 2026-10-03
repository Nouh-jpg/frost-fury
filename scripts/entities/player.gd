extends CharacterBody2D

signal attack_landed(enemy: Node2D, damage: int)

enum State {
	IDLE,
	MOVE,
	JUMP,
	FALL,
	ATTACK_1,
	ATTACK_2,
	ATTACK_3,
	BLITZ,
	KICK_SPHERE,
	HURT,
	DEAD
}

@export var move_speed: float = 140.0
@export var sprint_multiplier: float = 1.35
@export var jump_velocity: float = -340.0
@export var gravity: float = 850.0

var current_state: State = State.IDLE
var facing_direction: float = 1.0 # 1.0 = right, -1.0 = left
var combo_step: int = 0
var combo_window_timer: float = 0.0
var state_timer: float = 0.0

var speed_boost_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var kick_area: Area2D = $KickArea
@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
	add_to_group("player")
	attack_area.body_entered.connect(_on_attack_body_entered)
	attack_area.area_entered.connect(_on_attack_area_entered)
	_set_attack_hitbox_active(false)

func _physics_process(delta: float) -> void:
	if speed_boost_timer > 0.0:
		speed_boost_timer -= delta
		
	# Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Process states
	match current_state:
		State.IDLE, State.MOVE:
			_handle_movement(delta)
			_check_combat_inputs()
		State.JUMP, State.FALL:
			_handle_air_movement(delta)
			_check_air_combat_inputs()
		State.ATTACK_1, State.ATTACK_2, State.ATTACK_3, State.BLITZ, State.KICK_SPHERE:
			_handle_attack_state(delta)
		State.HURT:
			_handle_hurt_state(delta)
			
	move_and_slide()
	_update_animation()

func _handle_movement(delta: float) -> void:
	var input_x := Input.get_axis("move_left", "move_right")
	var current_spd := move_speed * (1.3 if speed_boost_timer > 0.0 else 1.0)
	
	if Input.is_action_pressed("blitz"):
		current_spd *= sprint_multiplier
		
	if input_x != 0.0:
		velocity.x = input_x * current_spd
		facing_direction = signf(input_x)
		sprite.flip_h = (facing_direction < 0.0)
		_adjust_hitbox_directions()
		current_state = State.MOVE
	else:
		velocity.x = move_toward(velocity.x, 0, current_spd * 8.0 * delta)
		current_state = State.IDLE
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity * (1.15 if speed_boost_timer > 0.0 else 1.0)
		current_state = State.JUMP
		SoundManager.play("jump")

func _handle_air_movement(delta: float) -> void:
	var input_x := Input.get_axis("move_left", "move_right")
	var air_spd := move_speed * 0.95
	
	if input_x != 0.0:
		velocity.x = input_x * air_spd
		facing_direction = signf(input_x)
		sprite.flip_h = (facing_direction < 0.0)
		_adjust_hitbox_directions()
	else:
		velocity.x = move_toward(velocity.x, 0, air_spd * 2.0 * delta)
		
	if velocity.y > 0.0:
		current_state = State.FALL
	if is_on_floor():
		current_state = State.IDLE

func _check_combat_inputs() -> void:
	# Check for Frost Sphere Kick first!
	if Input.is_action_just_pressed("attack"):
		var sphere = _get_nearby_frost_sphere()
		if sphere:
			_trigger_kick_sphere(sphere)
			return
			
		# Check Blitz attack (Rush attack)
		if Input.is_action_pressed("blitz"):
			_trigger_blitz_attack()
			return
			
		# Streets of Rage 3 Combo sequence
		_advance_combo()
		
	if Input.is_action_just_pressed("special"):
		_trigger_special()

func _check_air_combat_inputs() -> void:
	if Input.is_action_just_pressed("attack"):
		# Air dive kick
		velocity.y = 220.0
		velocity.x = facing_direction * 220.0
		_trigger_attack(State.ATTACK_2, 0.22, 22)
		SoundManager.play("punch_heavy")

func _advance_combo() -> void:
	if current_state == State.IDLE or current_state == State.MOVE:
		combo_step = 1
		_trigger_attack(State.ATTACK_1, 0.20, 15)
		SoundManager.play("punch", 1.0)
	elif current_state == State.ATTACK_1 and state_timer >= 0.08:
		combo_step = 2
		_trigger_attack(State.ATTACK_2, 0.22, 22)
		SoundManager.play("punch", 1.1)
	elif current_state == State.ATTACK_2 and state_timer >= 0.08:
		combo_step = 3
		_trigger_attack(State.ATTACK_3, 0.32, 35) # Finisher!
		SoundManager.play("uppercut", 1.0)

func _trigger_attack(attack_state: State, duration: float, damage: int) -> void:
	current_state = attack_state
	state_timer = 0.0
	_set_attack_hitbox_active(true)
	
	# Slight forward momentum step on punch
	if is_on_floor():
		velocity.x = facing_direction * (40.0 if attack_state != State.ATTACK_3 else 80.0)

func _trigger_blitz_attack() -> void:
	current_state = State.BLITZ
	state_timer = 0.0
	velocity.x = facing_direction * 260.0
	_set_attack_hitbox_active(true)
	SoundManager.play("blitz")
	GameManager.shake_screen(3.0, 0.15)

func _trigger_kick_sphere(sphere: Node2D) -> void:
	current_state = State.KICK_SPHERE
	state_timer = 0.0
	velocity.x = 0
	sphere.kick(facing_direction)

func _trigger_special() -> void:
	# Full screen Frost Nova
	if GameManager.consume_special():
		SoundManager.play("special")
		GameManager.shake_screen(8.0, 0.4)
		GameManager.hit_stop(0.12)
		# Freeze all on-screen enemies
		var enemies = get_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			if enemy.has_method("apply_frost"):
				enemy.apply_frost(100) # Instant freeze into sphere!

func _handle_attack_state(delta: float) -> void:
	state_timer += delta
	velocity.x = move_toward(velocity.x, 0, 300.0 * delta)
	
	var duration := 0.20
	match current_state:
		State.ATTACK_1: duration = 0.18
		State.ATTACK_2: duration = 0.20
		State.ATTACK_3: duration = 0.32
		State.BLITZ:    duration = 0.30
		State.KICK_SPHERE: duration = 0.22
		
	if state_timer >= duration:
		_set_attack_hitbox_active(false)
		current_state = State.IDLE

func _handle_hurt_state(delta: float) -> void:
	state_timer += delta
	velocity.x = move_toward(velocity.x, 0, 200.0 * delta)
	if state_timer >= 0.35:
		current_state = State.IDLE

func _get_nearby_frost_sphere() -> Node2D:
	var bodies = kick_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("frost_spheres"):
			return body
	return null

func _set_attack_hitbox_active(active: bool) -> void:
	attack_area.monitoring = active
	for col in attack_area.get_children():
		if col is CollisionShape2D:
			col.disabled = not active

func _adjust_hitbox_directions() -> void:
	attack_area.scale.x = facing_direction
	kick_area.scale.x = facing_direction

func _on_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body != self:
		_hit_enemy(body)

func _on_attack_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent and parent.is_in_group("enemies") and parent != self:
		_hit_enemy(parent)

func _hit_enemy(enemy: Node2D) -> void:
	if enemy.has_method("take_hit"):
		var dmg := 15
		var frost := 30
		if current_state == State.ATTACK_2:
			dmg = 22
			frost = 40
		elif current_state == State.ATTACK_3:
			dmg = 35
			frost = 60 # Launches / nearly freezes
		elif current_state == State.BLITZ:
			dmg = 30
			frost = 50
			
		enemy.take_hit(dmg, frost, facing_direction)
		GameManager.add_hit(100)
		GameManager.hit_stop(0.06)
		GameManager.shake_screen(2.5, 0.08)

func take_damage(amount: int, push_dir: float) -> void:
	if current_state == State.HURT or current_state == State.DEAD:
		return
	GameManager.damage_player(amount)
	SoundManager.play("punch_heavy")
	current_state = State.HURT
	state_timer = 0.0
	velocity.x = push_dir * 120.0
	velocity.y = -80.0

func apply_speed_boost(duration: float = 15.0) -> void:
	speed_boost_timer = duration

func _update_animation() -> void:
	# Animate using frames from the 8x4 hero sheet
	match current_state:
		State.IDLE:
			sprite.frame = int(fmod(Time.get_ticks_msec() / 200.0, 4.0)) # row 0, frames 0-3
		State.MOVE:
			sprite.frame = 8 + int(fmod(Time.get_ticks_msec() / 110.0, 6.0)) # row 1, frames 0-5
		State.JUMP:
			sprite.frame = 6 # row 0, frame 6
		State.FALL:
			sprite.frame = 7 # row 0, frame 7
		State.ATTACK_1:
			sprite.frame = 16 + (0 if state_timer < 0.09 else 1) # row 2
		State.ATTACK_2:
			sprite.frame = 18 + (0 if state_timer < 0.10 else 1) # row 2
		State.ATTACK_3:
			sprite.frame = 20 + clampi(int(state_timer / 0.10), 0, 2) # row 2
		State.BLITZ:
			sprite.frame = 24 + clampi(int(state_timer / 0.10), 0, 2) # row 3
		State.KICK_SPHERE:
			sprite.frame = 27 + clampi(int(state_timer / 0.07), 0, 2) # row 3
		State.HURT:
			sprite.frame = 4 # row 0, frame 4
