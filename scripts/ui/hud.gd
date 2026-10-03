extends CanvasLayer

@onready var score_label: Label = $TopBar/ScoreContainer/ScoreLabel
@onready var high_score_label: Label = $TopBar/ScoreContainer/HighScoreLabel
@onready var hp_bar: ProgressBar = $TopBar/StatusContainer/HPBar
@onready var special_bar: ProgressBar = $TopBar/StatusContainer/SpecialBar
@onready var lives_label: Label = $TopBar/StatusContainer/LivesLabel
@onready var combo_label: Label = $CenterOverlay/ComboLabel
@onready var stage_label: Label = $TopBar/StageLabel

var combo_anim_scale: float = 1.0

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.player_health_changed.connect(_on_health_changed)
	GameManager.special_meter_changed.connect(_on_special_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.combo_updated.connect(_on_combo_updated)
	
	_update_all()

func _process(delta: float) -> void:
	if combo_label.visible and combo_anim_scale > 1.0:
		combo_anim_scale = move_toward(combo_anim_scale, 1.0, 4.0 * delta)
		combo_label.scale = Vector2(combo_anim_scale, combo_anim_scale)

func _update_all() -> void:
	_on_score_changed(GameManager.score)
	_on_health_changed(GameManager.player_health, GameManager.player_max_health)
	_on_special_changed(GameManager.special_meter, GameManager.max_special_meter)
	_on_lives_changed(GameManager.lives)
	combo_label.visible = false

func _on_score_changed(new_score: int) -> void:
	score_label.text = "1P %06d" % new_score
	high_score_label.text = "HI %06d" % GameManager.high_score

func _on_health_changed(curr: int, max_hp: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = curr

func _on_special_changed(curr: float, max_meter: float) -> void:
	special_bar.max_value = max_meter
	special_bar.value = curr

func _on_lives_changed(new_lives: int) -> void:
	lives_label.text = "REST x %d" % new_lives

func _on_combo_updated(hits: int, points: int) -> void:
	if hits >= 2:
		combo_label.visible = true
		combo_label.text = "%d HITS!\n+%d PTS" % [hits, points]
		combo_anim_scale = 1.45
	else:
		combo_label.visible = false
