extends Control

@onready var stats_label: Label = %StatsLabel

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

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
