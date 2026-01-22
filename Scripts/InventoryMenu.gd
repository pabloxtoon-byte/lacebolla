extends Control

@onready var stats_label: Label = %StatsLabel
@onready var grid: GridContainer = %Grid

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_slots()

func _setup_slots() -> void:
	for slot in grid.get_children():
		var label := Label.new()
		label.name = "ItemLabel"
		label.horizontal_alignment = 1
		label.vertical_alignment = 1
		label.custom_minimum_size = Vector2(48, 48)
		slot.add_child(label)

func refresh() -> void:
	var stats := GameState.stats
	stats_label.text = "Clase: %s\nVida: %d\nDaño: %d\nVelocidad: %d\nCadencia: %.2f\nCrítico: %d%%" % [
		GameState.selected_class.capitalize(),
		stats["max_hp"],
		stats["damage"],
		int(stats["move_speed"]),
		stats["attack_rate"],
		int(GameState.crit_chance * 100.0)
	]
	for i in range(grid.get_child_count()):
		var slot := grid.get_child(i)
		var label := slot.get_node_or_null("ItemLabel") as Label
		if not label:
			continue
		var item := GameState.inventory[i] if i < GameState.inventory.size() else ""
		label.text = item
