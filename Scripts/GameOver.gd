extends Control

func _on_retry_pressed() -> void:
	GameState.reset_run()
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
