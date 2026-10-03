extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var dialogue_box: CanvasLayer = $DialogueBox
@onready var hud: CanvasLayer = $HUD
@onready var touch_controls: CanvasLayer = $TouchControls
@onready var enemy_container: Node2D = $EnemyContainer
@onready var clear_banner: Control = $HUD/CenterOverlay/StageClearBanner

var shake_intensity: float = 0.0
var shake_timer: float = 0.0
var original_camera_pos: Vector2 = Vector2.ZERO

var goblin_scene = preload("res://scenes/enemies/goblin_brawler.tscn")
var wave_index: int = 0
var total_waves: int = 3
var enemies_alive: int = 0

func _ready() -> void:
	original_camera_pos = camera.position
	clear_banner.visible = false
	GameManager.screen_shake_requested.connect(_on_screen_shake)
	dialogue_box.dialogue_finished.connect(_on_intro_dialogue_finished)
	
	# Start with retro Sega Genesis opening narrative!
	_play_intro_story()

func _play_intro_story() -> void:
	var story = [
		{
			"speaker": "IGNIS THE ASHLORD",
			"portrait": "ignis",
			"text": "Tremble, Knight of the Frost! My Cinder Legion marches upon the Citadel! You cannot freeze hell itself!"
		},
		{
			"speaker": "KAELEN",
			"portrait": "kaelen",
			"text": "Your flames bring only ruin, Ignis. My fists will freeze your legion solid, and I will shatter your crown!"
		},
		{
			"speaker": "IGNIS THE ASHLORD",
			"portrait": "ignis",
			"text": "Brawlers! Swarm this fool! Tear off his armor!"
		}
	]
	dialogue_box.start_dialogue(story)

func _on_intro_dialogue_finished() -> void:
	_spawn_next_wave()

func _spawn_next_wave() -> void:
	wave_index += 1
	var count := 2 + wave_index
	enemies_alive = count
	
	var spawn_points = [
		Vector2(40, 200),
		Vector2(440, 200),
		Vector2(80, 110),
		Vector2(400, 110),
		Vector2(240, 50)
	]
	
	for i in range(count):
		var pos: Vector2 = spawn_points[i % spawn_points.size()]
		var enemy = goblin_scene.instantiate()
		enemy.position = pos
		enemy.enemy_defeated.connect(_on_enemy_defeated)
		enemy_container.add_child(enemy)

func _on_enemy_defeated(pos: Vector2, pts: int) -> void:
	enemies_alive -= 1
	GameManager.add_score(pts)
	
	if enemies_alive <= 0:
		if wave_index < total_waves:
			await get_tree().create_timer(1.2).timeout
			_spawn_next_wave()
		else:
			_stage_complete()

func _stage_complete() -> void:
	clear_banner.visible = true
	SoundManager.play("victory", 1.0)
	GameManager.add_score(5000)
	await get_tree().create_timer(4.0).timeout
	# Transition to Act 1 Boss or replay loop
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _process(delta: float) -> void:
	if shake_timer > 0.0:
		shake_timer -= delta
		camera.position = original_camera_pos + Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		if shake_timer <= 0.0:
			camera.position = original_camera_pos

func _on_screen_shake(intensity: float, duration: float) -> void:
	shake_intensity = intensity
	shake_timer = duration
