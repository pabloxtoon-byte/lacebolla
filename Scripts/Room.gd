extends Node2D

signal room_cleared
signal enemy_killed

@export var size: Vector2i = Vector2i(12, 9)
@export var tile_size: int = 16

var coord: Vector2i = Vector2i.ZERO
var neighbors: Dictionary = {}
var cleared: bool = false
var enemy_count: int = 0

@onready var floor_root: Node2D = $Floor
@onready var wall_root: Node2D = $Walls
@onready var door_root: Node2D = $Doors
@onready var obstacles_root: Node2D = $Obstacles

func setup(room_coord: Vector2i, room_neighbors: Dictionary) -> void:
	coord = room_coord
	neighbors = room_neighbors
	_generate_floor()
	_generate_walls()
	_spawn_obstacles()
	_add_torches()

func _generate_floor() -> void:
	_clear_children(floor_root)
	var floor_tex: Texture2D = ProceduralSprite.make_tile_texture(Color(0.2, 0.2, 0.25), Color(0.25, 0.25, 0.3))
	for y in range(size.y):
		for x in range(size.x):
			var tile: Sprite2D = Sprite2D.new()
			tile.texture = floor_tex
			tile.position = Vector2(x * tile_size, y * tile_size)
			floor_root.add_child(tile)

func _generate_walls() -> void:
	_clear_children(wall_root)
	_clear_children(door_root)
	var wall_tex: Texture2D = ProceduralSprite.make_tile_texture(Color(0.12, 0.12, 0.14), Color(0.2, 0.2, 0.25))
	var room_width: int = size.x * tile_size
	var room_height: int = size.y * tile_size
	for x in range(size.x):
		_add_wall_tile(Vector2(x * tile_size, -tile_size), wall_tex)
		_add_wall_tile(Vector2(x * tile_size, room_height), wall_tex)
	for y in range(size.y):
		_add_wall_tile(Vector2(-tile_size, y * tile_size), wall_tex)
		_add_wall_tile(Vector2(room_width, y * tile_size), wall_tex)
	_create_door("up", Vector2(room_width * 0.5, -tile_size * 0.5))
	_create_door("down", Vector2(room_width * 0.5, room_height + tile_size * 0.5))
	_create_door("left", Vector2(-tile_size * 0.5, room_height * 0.5))
	_create_door("right", Vector2(room_width + tile_size * 0.5, room_height * 0.5))

func _add_wall_tile(pos: Vector2, tex: Texture2D) -> void:
	var tile: Sprite2D = Sprite2D.new()
	tile.texture = tex
	tile.position = pos
	wall_root.add_child(tile)

func _create_door(dir: String, pos: Vector2) -> void:
	if not neighbors.has(dir):
		return
	var door: StaticBody2D = StaticBody2D.new()
	var shape: CollisionShape2D = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(12, 12)
	shape.position = Vector2.ZERO
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = ProceduralSprite.make_tile_texture(Color(0.35, 0.2, 0.1), Color(0.5, 0.3, 0.1))
	sprite.position = Vector2.ZERO
	door.position = pos
	door.add_child(sprite)
	door.add_child(shape)
	door_root.add_child(door)
	door.set_meta("dir", dir)

func _spawn_obstacles() -> void:
	_clear_children(obstacles_root)
	var rock_tex: Texture2D = ProceduralSprite.make_tile_texture(Color(0.25, 0.25, 0.28), Color(0.35, 0.35, 0.4))
	for i in range(3):
		var rock: StaticBody2D = StaticBody2D.new()
		rock.position = Vector2(randi_range(2, size.x - 3) * tile_size, randi_range(2, size.y - 3) * tile_size)
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = rock_tex
		rock.add_child(sprite)
		var shape: CollisionShape2D = CollisionShape2D.new()
		shape.shape = RectangleShape2D.new()
		shape.shape.size = Vector2(12, 12)
		rock.add_child(shape)
		obstacles_root.add_child(rock)

func spawn_enemies(enemy_scenes: Array, player: Node2D) -> void:
	for scene in enemy_scenes:
		var enemy: Node2D = scene.instantiate()
		add_child(enemy)
		enemy.global_position = global_position + Vector2(randi_range(2, size.x - 2) * tile_size, randi_range(2, size.y - 2) * tile_size)
		enemy.set_target(player)
		enemy.died.connect(_on_enemy_died)
		enemy_count += 1

func _on_enemy_died() -> void:
	enemy_count -= 1
	emit_signal("enemy_killed")
	if enemy_count <= 0 and not cleared:
		cleared = true
		_open_doors()
		emit_signal("room_cleared")

func _open_doors() -> void:
	for door in door_root.get_children():
		door.queue_free()

func _add_torches() -> void:
	var light_tex: Texture2D = ProceduralSprite.make_light_texture()
	for pos in [Vector2(24, 24), Vector2(size.x * tile_size - 24, 24)]:
		var light: PointLight2D = PointLight2D.new()
		light.texture = light_tex
		light.energy = 0.8
		light.position = pos
		add_child(light)

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
