extends Area2D

@export var speed: float = 240.0
@export var damage: int = 10
var velocity := Vector2.ZERO

func _ready() -> void:
	$Sprite2D.texture = ProceduralSprite.make_projectile_texture(Color(0.6, 0.8, 1.0))

func _process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
