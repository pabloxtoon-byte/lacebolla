extends Area2D

@export var kind: String = "coin"

func _ready() -> void:
	var color: Color = Color(0.9, 0.8, 0.3)
	if kind == "key":
		color = Color(0.8, 0.7, 0.4)
	$Sprite2D.texture = ProceduralSprite.make_projectile_texture(color)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		if kind == "coin":
			GameState.coins += 1
		elif kind == "key":
			GameState.keys += 1
		queue_free()
