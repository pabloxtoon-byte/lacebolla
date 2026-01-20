extends Control

@onready var desc_label: Label = %DescLabel

func _ready() -> void:
	_update_desc(GameState.CLASS_WARRIOR)

func _update_desc(class_id: String) -> void:
	var stats := GameState.BASE_STATS[class_id]
	match class_id:
		GameState.CLASS_WARRIOR:
			desc_label.text = "Guerrero: vida alta, espada melee.\nVida: %d  Daño: %d" % [stats["max_hp"], stats["damage"]]
		GameState.CLASS_MAGE:
			desc_label.text = "Mago: vida baja, proyectil mágico.\nVida: %d  Daño: %d" % [stats["max_hp"], stats["damage"]]
		GameState.CLASS_ROGUE:
			desc_label.text = "Pícaro: velocidad alta, dash.\nVida: %d  Daño: %d" % [stats["max_hp"], stats["damage"]]

func _on_warrior_pressed() -> void:
	GameState.set_class(GameState.CLASS_WARRIOR)
	_start_game()

func _on_mage_pressed() -> void:
	GameState.set_class(GameState.CLASS_MAGE)
	_start_game()

func _on_rogue_pressed() -> void:
	GameState.set_class(GameState.CLASS_ROGUE)
	_start_game()

func _on_warrior_mouse_entered() -> void:
	_update_desc(GameState.CLASS_WARRIOR)

func _on_mage_mouse_entered() -> void:
	_update_desc(GameState.CLASS_MAGE)

func _on_rogue_mouse_entered() -> void:
	_update_desc(GameState.CLASS_ROGUE)

func _start_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
