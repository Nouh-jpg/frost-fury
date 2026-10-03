extends CharacterBody2D

signal sphere_shattered(pos: Vector2)
signal enemy_bowled(enemy: Node2D)

const ROLL_SPEED: float = 380.0
const GRAVITY: float = 850.0
const MAX_BOUNCES: int = 4

var is_rolling: bool = false
var roll_direction: float = 0.0
var bounce_count: int = 0
var roll_time: float = 0.0
var max_roll_time: float = 4.5
var breakout_timer: float = 7.0
var original_enemy_data: Dictionary = {}

var multikill_count: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Hitbox
@onready var anim_timer: float = 0.0
@onready var current_frame: int = 0

func _ready() -> void:
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	add_to_group("frost_spheres")

func _physics_process(delta: float) -> void:
	if not is_rolling:
		# Stationary frozen ball waiting for player kick
		velocity.y += GRAVITY * delta
		velocity.x = move_toward(velocity.x, 0, 400.0 * delta)
		move_and_slide()
		
		# Breakout countdown
		breakout_timer -= delta
		if breakout_timer <= 2.0:
			# Jiggle / warning shake
			sprite.position.x = randf_range(-1.5, 1.5)
		if breakout_timer <= 0.0:
			_breakout()
		return
		
	# Rolling Wrecking Ball State!
	velocity.y += GRAVITY * delta
	velocity.x = roll_direction * ROLL_SPEED
	
	# Animate rolling sprite
	anim_timer += delta * 18.0
	sprite.rotation += roll_direction * delta * 12.0
	
	roll_time += delta
	if roll_time >= max_roll_time:
		shatter()
		return
		
	var collided := move_and_slide()
	if is_on_wall():
		_bounce()

func kick(direction: float) -> void:
	if is_rolling:
		return
	is_rolling = true
	roll_direction = direction if direction != 0.0 else 1.0
	velocity.y = -90.0 # Small pop up
	SoundManager.play("kick_sphere")
	GameManager.shake_screen(4.0, 0.15)
	sprite.position = Vector2.ZERO

func _bounce() -> void:
	bounce_count += 1
	roll_direction = -roll_direction
	velocity.x = roll_direction * ROLL_SPEED
	SoundManager.play("sphere_bounce")
	GameManager.shake_screen(3.5, 0.1)
	
	if bounce_count >= MAX_BOUNCES:
		shatter()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if not is_rolling:
		return
	if body.is_in_group("enemies") and body != self:
		_bowl_enemy(body)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if not is_rolling:
		return
	var parent := area.get_parent()
	if parent and parent.is_in_group("enemies") and parent != self:
		_bowl_enemy(parent)

func _bowl_enemy(enemy: Node2D) -> void:
	if enemy.has_method("die_from_sphere"):
		multikill_count += 1
		var bonus_pts := 200 * multikill_count
		GameManager.add_hit(bonus_pts)
		enemy.die_from_sphere(roll_direction)
		SoundManager.play("punch_heavy")
		GameManager.hit_stop(0.06)
		GameManager.shake_screen(5.0, 0.2)
		
		# If high multikill, drop loot!
		if multikill_count >= 2:
			_drop_loot()

func _drop_loot() -> void:
	var pickup_scene = load("res://scenes/pickup.tscn")
	if pickup_scene:
		var pickup = pickup_scene.instantiate()
		pickup.global_position = global_position + Vector2(randf_range(-10, 10), -12)
		get_parent().call_deferred("add_child", pickup)

func shatter() -> void:
	SoundManager.play("shatter")
	GameManager.shake_screen(6.0, 0.25)
	sphere_shattered.emit(global_position)
	_drop_loot()
	queue_free()

func _breakout() -> void:
	# Enemy unfreezes if ignored
	SoundManager.play("shatter")
	if original_enemy_data.has("scene"):
		var enemy_scene: PackedScene = original_enemy_data["scene"]
		var enemy = enemy_scene.instantiate()
		enemy.global_position = global_position
		get_parent().add_child(enemy)
	queue_free()
