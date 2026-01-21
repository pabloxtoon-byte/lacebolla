extends CharacterBody2D

signal died

@export var max_hp: int = 30
@export var damage: int = 8
@export var move_speed: float = 60.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

var hp: int
var target: Node2D

func _ready() -> void:
	hp = max_hp
	var body_shape: CollisionShape2D = get_node_or_null("BodyCollision") as CollisionShape2D
	if body_shape and body_shape.shape is RectangleShape2D:
		body_shape.shape.size = Vector2(12, 12)
	var hit_shape: CollisionShape2D = $Hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if hit_shape and hit_shape.shape is RectangleShape2D:
		hit_shape.shape.size = Vector2(12, 12)

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		emit_signal("died")
		queue_free()

func get_damage() -> int:
	return damage

func set_target(node: Node2D) -> void:
	target = node
