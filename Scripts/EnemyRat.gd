extends EnemyBase

var zigzag_time := 0.0

func _ready() -> void:
	super._ready()
	move_speed = 90.0
	sprite.sprite_frames = ProceduralSprite.make_enemy_frames(Color(0.5, 0.4, 0.3), Color(0.7, 0.6, 0.5), true)
	sprite.play("walk")

func _physics_process(delta: float) -> void:
	if not target:
		return
	zigzag_time += delta * 6.0
	var dir := (target.global_position - global_position).normalized()
	var perpendicular := Vector2(-dir.y, dir.x) * sin(zigzag_time) * 0.5
	velocity = (dir + perpendicular).normalized() * move_speed
	move_and_slide()
