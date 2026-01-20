extends Area2D

signal opened

var is_open := false

func _ready() -> void:
	$Sprite2D.texture = ProceduralSprite.make_tile_texture(Color(0.4, 0.25, 0.1), Color(0.6, 0.35, 0.15))

func _on_body_entered(body: Node) -> void:
	if is_open:
		return
	if body is CharacterBody2D:
		is_open = true
		emit_signal("opened")
		queue_free()
