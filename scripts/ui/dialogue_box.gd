extends CanvasLayer

signal dialogue_finished()

@onready var panel: PanelContainer = $BoxContainer/Panel
@onready var portrait: TextureRect = $BoxContainer/Panel/HBox/Portrait
@onready var name_label: Label = $BoxContainer/Panel/HBox/VBox/NameLabel
@onready var text_label: Label = $BoxContainer/Panel/HBox/VBox/TextLabel
@onready var continue_prompt: Label = $BoxContainer/Panel/HBox/VBox/ContinuePrompt

var dialogue_lines: Array = []
var current_line_idx: int = 0
var typing_speed: float = 0.025
var char_timer: float = 0.0
var is_typing: bool = false
var visible_chars: int = 0

var portraits: Dictionary = {
	"kaelen": preload("res://assets/ui/portraits/hero_portrait.png"),
	"ignis": preload("res://assets/ui/portraits/villain_portrait.png")
}

func _ready() -> void:
	visible = false

func start_dialogue(lines: Array) -> void:
	dialogue_lines = lines
	current_line_idx = 0
	visible = true
	get_tree().paused = true
	_show_current_line()

func _input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event.is_action_just_pressed("attack") or event.is_action_just_pressed("jump") or event.is_action_just_pressed("pause"):
		if is_typing:
			# Skip to end of line
			text_label.visible_characters = -1
			is_typing = false
			continue_prompt.visible = true
		else:
			current_line_idx += 1
			if current_line_idx < dialogue_lines.size():
				_show_current_line()
			else:
				_close_dialogue()

func _process(delta: float) -> void:
	if not visible or not is_typing:
		return
		
	char_timer += delta
	if char_timer >= typing_speed:
		char_timer = 0.0
		visible_chars += 1
		text_label.visible_characters = visible_chars
		if visible_chars % 3 == 0:
			SoundManager.play("punch", 2.2) # Blip sound
			
		if visible_chars >= text_label.text.length():
			is_typing = false
			continue_prompt.visible = true

func _show_current_line() -> void:
	var item: Dictionary = dialogue_lines[current_line_idx]
	name_label.text = item.get("speaker", "UNKNOWN")
	text_label.text = item.get("text", "")
	
	var portrait_key: String = item.get("portrait", "kaelen").to_lower()
	if portraits.has(portrait_key):
		portrait.texture = portraits[portrait_key]
		
	text_label.visible_characters = 0
	visible_chars = 0
	char_timer = 0.0
	is_typing = true
	continue_prompt.visible = false

func _close_dialogue() -> void:
	visible = false
	get_tree().paused = false
	dialogue_finished.emit()
