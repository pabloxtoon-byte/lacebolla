extends EnemyBase

var move_time := 0.0

func _ready() -> void:
	super._ready()
	move_speed = 75.0
	max_hp = 25
	damage = 10
	sprite.sprite_frames = ProceduralSprite.make_enemy_frames(Color(0.3, 0.3, 0.6), Color(0.5, 0.5, 0.9), true)
	sprite.play("walk")

func _physics_process(delta: float) -> void:
	if not target:
		return
	move_time += delta
	var dir := (target.global_position - global_position).normalized()
	var wobble := Vector2(cos(move_time * 5.0), sin(move_time * 6.0)) * 0.4
	velocity = (dir + wobble).normalized() * move_speed
	move_and_slide()
