extends Area2D

enum Type {
	POTION,
	SPEED_BOOT,
	DIAMOND,
	BLITZ_STAR
}

@export var item_type: Type = Type.POTION

var bob_offset: float = 0.0
var initial_y: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	initial_y = position.y
	bob_offset = randf_range(0.0, TAU)
	
	# Randomize item if default
	var rand_val := randf()
	if rand_val < 0.35:
		item_type = Type.POTION
	elif rand_val < 0.60:
		item_type = Type.SPEED_BOOT
	elif rand_val < 0.85:
		item_type = Type.DIAMOND
	else:
		item_type = Type.BLITZ_STAR
		
	sprite.frame = item_type
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	bob_offset += delta * 4.0
	position.y = initial_y + sin(bob_offset) * 3.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		match item_type:
			Type.POTION:
				GameManager.heal_player(40)
				GameManager.add_score(500)
			Type.SPEED_BOOT:
				if body.has_method("apply_speed_boost"):
					body.apply_speed_boost(15.0)
				GameManager.add_score(800)
				SoundManager.play("victory", 1.3)
			Type.DIAMOND:
				GameManager.add_score(1500)
				SoundManager.play("pickup", 1.2)
			Type.BLITZ_STAR:
				GameManager.add_special(100.0)
				GameManager.add_score(1000)
				SoundManager.play("victory", 1.5)
				
		queue_free()
