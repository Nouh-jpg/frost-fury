extends CharacterBody2D

signal enemy_defeated(pos: Vector2, points: int)

@export var max_health: int = 50
@export var move_speed: float = 60.0
@export var attack_damage: int = 12
@export var attack_range: float = 24.0
@export var detection_range: float = 140.0
@export var points_reward: int = 250

var current_health: int = 50
var frost_meter: int = 0
var max_frost: int = 100

var facing_direction: float = -1.0
var state_timer: float = 0.0
var attack_cooldown: float = 0.0

enum State { PATROL, CHASE, ATTACK, HURT, FROZEN }
var current_state: State = State.PATROL

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox

var target_player: Node2D = null

func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += 850.0 * delta
		
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
		
	_find_player()
	
	match current_state:
		State.PATROL:
			_handle_patrol(delta)
		State.CHASE:
			_handle_chase(delta)
		State.ATTACK:
			_handle_attack(delta)
		State.HURT:
			_handle_hurt(delta)
			
	move_and_slide()
	_update_animation()

func _find_player() -> void:
	if not target_player or not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0]

func _handle_patrol(delta: float) -> void:
	state_timer += delta
	if state_timer >= 2.5:
		state_timer = 0.0
		facing_direction = -facing_direction
		
	velocity.x = facing_direction * (move_speed * 0.5)
	sprite.flip_h = (facing_direction > 0.0)
	
	if target_player and global_position.distance_to(target_player.global_position) < detection_range:
		current_state = State.CHASE

func _handle_chase(delta: float) -> void:
	if not target_player:
		current_state = State.PATROL
		return
		
	var dist := global_position.distance_to(target_player.global_position)
	var dir_to_p := signf(target_player.global_position.x - global_position.x)
	if dir_to_p != 0.0:
		facing_direction = dir_to_p
	sprite.flip_h = (facing_direction > 0.0)
	
	if dist <= attack_range and attack_cooldown <= 0.0:
		_start_attack()
	else:
		velocity.x = facing_direction * move_speed
		
	if dist > detection_range * 1.5:
		current_state = State.PATROL

func _start_attack() -> void:
	current_state = State.ATTACK
	state_timer = 0.0
	velocity.x = 0

func _handle_attack(delta: float) -> void:
	state_timer += delta
	if state_timer >= 0.15 and state_timer < 0.25:
		# Active punch window
		_check_punch_hit()
	if state_timer >= 0.40:
		attack_cooldown = 1.2
		current_state = State.CHASE

func _check_punch_hit() -> void:
	if target_player and global_position.distance_to(target_player.global_position) <= attack_range:
		if target_player.has_method("take_damage"):
			target_player.take_damage(attack_damage, facing_direction)

func _handle_hurt(delta: float) -> void:
	state_timer += delta
	velocity.x = move_toward(velocity.x, 0, 300.0 * delta)
	if state_timer >= 0.25:
		current_state = State.CHASE

func take_hit(damage: int, frost_gain: int, push_dir: float) -> void:
	current_health -= damage
	frost_meter += frost_gain
	current_state = State.HURT
	state_timer = 0.0
	velocity.x = push_dir * 110.0
	velocity.y = -60.0
	SoundManager.play("punch")
	
	if frost_meter >= max_frost:
		_turn_into_frost_sphere()
	elif current_health <= 0:
		_die()

func apply_frost(amount: int) -> void:
	frost_meter += amount
	if frost_meter >= max_frost:
		_turn_into_frost_sphere()

func _turn_into_frost_sphere() -> void:
	SoundManager.play("freeze")
	GameManager.shake_screen(3.5, 0.15)
	
	var sphere_scene = load("res://scenes/frost_sphere.tscn")
	if sphere_scene:
		var sphere = sphere_scene.instantiate()
		sphere.global_position = global_position
		sphere.original_enemy_data = {
			"scene": load(scene_file_path if scene_file_path else "res://scenes/enemies/goblin_brawler.tscn")
		}
		get_parent().call_deferred("add_child", sphere)
	queue_free()

func die_from_sphere(roll_dir: float) -> void:
	SoundManager.play("shatter")
	enemy_defeated.emit(global_position, points_reward)
	queue_free()

func _die() -> void:
	SoundManager.play("punch_heavy")
	enemy_defeated.emit(global_position, points_reward)
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and current_state == State.ATTACK:
		if body.has_method("take_damage"):
			body.take_damage(attack_damage, facing_direction)

func _update_animation() -> void:
	# 8 frames wide, 3 rows high
	# Row 0: Idle (0-3), Walk (4-7)
	# Row 1: Attack (8-10), Hurt (11-12), Freeze1 (13), Freeze2 (14), Freeze3 (15)
	if frost_meter >= 66:
		sprite.frame = 14 # row 1, col 6
	elif frost_meter >= 33:
		sprite.frame = 13 # row 1, col 5
	else:
		match current_state:
			State.PATROL, State.CHASE:
				if abs(velocity.x) > 5.0:
					sprite.frame = 4 + int(fmod(Time.get_ticks_msec() / 140.0, 4.0))
				else:
					sprite.frame = int(fmod(Time.get_ticks_msec() / 250.0, 4.0))
			State.ATTACK:
				sprite.frame = 8 + clampi(int(state_timer / 0.12), 0, 2)
			State.HURT:
				sprite.frame = 11
