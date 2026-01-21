extends Node2D

@export var room_scene: PackedScene
@export var player_scene: PackedScene
@export var enemy_scenes: Array[PackedScene]
@export var coin_scene: PackedScene
@export var key_scene: PackedScene
@export var chest_scene: PackedScene

# AudioStreamPlayer placeholders can be added to UI or World for loot/door SFX.

@onready var world: Node2D = $World
@onready var camera: Camera2D = $Camera2D
@onready var ui: Control = $HUD/UI
@onready var reward_select: Control = $HUD/RewardSelect
@onready var pause_menu: Control = $HUD/PauseMenu

var rooms: Dictionary = {}
var player: CharacterBody2D
var room_size: Vector2i = Vector2i(12, 9)
var room_spacing: Vector2i = Vector2i(220, 180)

func _ready() -> void:
	randomize()
	GameState.reset_run()
	_generate_dungeon()
	_spawn_player()
	_populate_rooms()
	ui.update_stats()
	reward_select.perk_selected.connect(_on_perk_selected)
	pause_menu.visible = false
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if player:
		camera.global_position = player.global_position
	ui.update_stats()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	pause_menu.visible = get_tree().paused

func _generate_dungeon() -> void:
	rooms.clear()
	_clear_children(world)
	var coords: Array[Vector2i] = _random_walk_rooms(8)
	var coord_set: Dictionary = {}
	for c in coords:
		coord_set[c] = true
	for coord in coords:
		var neighbors: Dictionary = {}
		if coord_set.has(coord + Vector2i(0, -1)):
			neighbors["up"] = coord + Vector2i(0, -1)
		if coord_set.has(coord + Vector2i(0, 1)):
			neighbors["down"] = coord + Vector2i(0, 1)
		if coord_set.has(coord + Vector2i(-1, 0)):
			neighbors["left"] = coord + Vector2i(-1, 0)
		if coord_set.has(coord + Vector2i(1, 0)):
			neighbors["right"] = coord + Vector2i(1, 0)
		var room: Node2D = room_scene.instantiate()
		world.add_child(room)
		room.position = Vector2(coord.x * room_spacing.x, coord.y * room_spacing.y)
		room.setup(coord, neighbors)
		room.room_cleared.connect(_on_room_cleared.bind(room))
		room.enemy_killed.connect(_on_enemy_killed)
		rooms[coord] = room

func _spawn_player() -> void:
	var start_coord := Vector2i.ZERO
	player = player_scene.instantiate()
	world.add_child(player)
	var start_room: Node2D = rooms[start_coord]
	player.global_position = start_room.global_position + Vector2(room_size.x * 8, room_size.y * 8)
	player.died.connect(_on_player_died)
	player.health_changed.connect(ui.update_health)
	camera.make_current()

func _populate_rooms() -> void:
	for room in rooms.values():
		_spawn_room_enemies(room)

func _spawn_room_enemies(room: Node) -> void:
	if room == rooms[Vector2i.ZERO]:
		return
	var count: int = randi_range(2, 4)
	var picks: Array[PackedScene] = []
	for i in range(count):
		picks.append(enemy_scenes.pick_random())
	room.spawn_enemies(picks, player)

func _on_enemy_killed() -> void:
	var leveled: bool = GameState.add_exp(1)
	if leveled:
		ui.show_message("Nuevo nivel")
		reward_select.show_rewards(GameState.get_random_perks())

func _on_room_cleared(room: Node) -> void:
	ui.show_message("Sala limpiada")	
	_spawn_loot(room)

func _spawn_loot(room: Node) -> void:
	for i in range(randi_range(2, 5)):
		var coin: Area2D = coin_scene.instantiate()
		world.add_child(coin)
		coin.global_position = room.global_position + Vector2(randi_range(40, 140), randi_range(40, 100))
	if randf() < 0.2:
		var key: Area2D = key_scene.instantiate()
		world.add_child(key)
		key.global_position = room.global_position + Vector2(randi_range(60, 120), randi_range(60, 110))
	if randf() < 0.4:
		var chest: Area2D = chest_scene.instantiate()
		world.add_child(chest)
		chest.global_position = room.global_position + Vector2(randi_range(60, 120), randi_range(50, 100))
		chest.opened.connect(_on_chest_opened)

func _on_chest_opened() -> void:
	ui.show_message("Cofre abierto")
	reward_select.show_rewards(GameState.get_random_perks())

func _on_perk_selected(perk: Dictionary) -> void:
	GameState.apply_perk(perk)
	if player:
		player.refresh_stats()
	ui.update_stats()

func _on_player_died() -> void:
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")

func _on_resume_pressed() -> void:
	_toggle_pause()

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _random_walk_rooms(count: int) -> Array[Vector2i]:
	var coords: Array[Vector2i] = [Vector2i.ZERO]
	while coords.size() < count:
		var current: Vector2i = coords.pick_random()
		var dir: Vector2i = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)].pick_random()
		var next: Vector2i = current + dir
		if not coords.has(next):
			coords.append(next)
	return coords

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
