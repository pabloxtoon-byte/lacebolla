extends CharacterBody2D

signal died
signal health_changed(current, max)

# AudioStreamPlayer nodes are placeholders for attack/hit SFX.
@export var projectile_scene: PackedScene

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var hurtbox: Area2D = $Hurtbox
@onready var attack_timer: Timer = $AttackCooldown
@onready var iframe_timer: Timer = $IFrameTimer
@onready var dash_timer: Timer = $DashTimer

var max_hp: int
var hp: int
var move_speed: float
var damage: int
var attack_rate: float
var is_attacking := false
var is_invulnerable := false
var facing := Vector2.DOWN
var dash_speed := 280.0

func _ready() -> void:
	_load_stats()
	setup_sprite()
	_configure_collisions()
	attack_area.monitoring = false
	emit_signal("health_changed", hp, max_hp)

func _load_stats(reset_hp: bool = true) -> void:
	var old_max: int = max_hp
	max_hp = GameState.stats["max_hp"]
	if reset_hp:
		hp = max_hp
	else:
		var diff: int = max_hp - old_max
		hp = clamp(hp + diff, 1, max_hp)
	move_speed = GameState.stats["move_speed"]
	damage = GameState.stats["damage"]
	attack_rate = GameState.stats["attack_rate"]
	attack_timer.wait_time = attack_rate

func setup_sprite() -> void:
	var body_color: Color = Color(0.3, 0.5, 0.8)
	var accent: Color = Color(0.9, 0.8, 0.6)
	if GameState.selected_class == GameState.CLASS_WARRIOR:
		body_color = Color(0.7, 0.3, 0.2)
		accent = Color(0.9, 0.8, 0.6)
	elif GameState.selected_class == GameState.CLASS_MAGE:
		body_color = Color(0.3, 0.4, 0.9)
		accent = Color(0.7, 0.9, 1.0)
	elif GameState.selected_class == GameState.CLASS_ROGUE:
		body_color = Color(0.2, 0.7, 0.4)
		accent = Color(0.8, 0.9, 0.6)
	sprite.sprite_frames = ProceduralSprite.make_character_frames(body_color, accent)
	sprite.play("walk")
	sprite.autoplay = ""

func _configure_collisions() -> void:
	var body_shape: RectangleShape2D = $BodyCollision.shape as RectangleShape2D
	body_shape.size = Vector2(12, 12)
	var attack_shape: RectangleShape2D = $AttackArea/AttackCollision.shape as RectangleShape2D
	attack_shape.size = Vector2(16, 16)
	var hurt_shape: RectangleShape2D = $Hurtbox/HurtboxCollision.shape as RectangleShape2D
	hurt_shape.size = Vector2(12, 12)

func _physics_process(_delta: float) -> void:
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input.length() > 0.1:
		facing = input.normalized()
		velocity = facing * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		try_attack()
	if event.is_action_pressed("dash") and GameState.selected_class == GameState.CLASS_ROGUE:
		try_dash()

func try_attack() -> void:
	if is_attacking:
		return
	is_attacking = true
	attack_timer.start()
	if GameState.selected_class == GameState.CLASS_MAGE:
		shoot_projectile()
	else:
		swing_melee()

func shoot_projectile() -> void:
	var projectile: Area2D = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position + facing * 12.0
	projectile.velocity = facing * projectile.speed
	projectile.damage = _roll_damage()

func swing_melee() -> void:
	attack_area.monitoring = true
	attack_area.rotation = facing.angle()
	attack_area.position = facing * 12.0
	$AttackTimer.start()

func _on_attack_timer_timeout() -> void:
	attack_area.monitoring = false

func _on_attack_cooldown_timeout() -> void:
	is_attacking = false

func try_dash() -> void:
	if dash_timer.time_left > 0.0:
		return
	is_invulnerable = true
	iframe_timer.start(0.3)
	velocity = facing * dash_speed
	move_and_slide()
	dash_timer.start(0.8)

func take_damage(amount: int) -> void:
	if is_invulnerable:
		return
	is_invulnerable = true
	hp = max(hp - amount, 0)
	iframe_timer.start(0.6)
	emit_signal("health_changed", hp, max_hp)
	if hp <= 0:
		emit_signal("died")

func heal(amount: int) -> void:
	hp = min(max_hp, hp + amount)
	emit_signal("health_changed", hp, max_hp)

func _on_iframe_timer_timeout() -> void:
	is_invulnerable = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.has_method("get_damage"):
		take_damage(area.get_damage())

func _on_attack_area_body_entered(body: Node) -> void:
	if body == self:
		return
	if body.has_method("take_damage"):
		body.take_damage(_roll_damage())

func _roll_damage() -> int:
	if randf() < GameState.crit_chance:
		return int(damage * 1.6)
	return damage

func refresh_stats() -> void:
	_load_stats(false)
	emit_signal("health_changed", hp, max_hp)
