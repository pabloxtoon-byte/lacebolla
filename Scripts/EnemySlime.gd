extends EnemyBase

@onready var hop_timer: Timer = $HopTimer

func _ready() -> void:
	super._ready()
	sprite.sprite_frames = ProceduralSprite.make_enemy_frames(Color(0.2, 0.8, 0.5), Color(0.4, 1.0, 0.7))
	sprite.play("walk")
	hop_timer.start()

func _on_hop_timer_timeout() -> void:
	if target:
		var dir := (target.global_position - global_position).normalized()
		velocity = dir * move_speed * 1.4
		move_and_slide()
