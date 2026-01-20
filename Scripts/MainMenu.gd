extends Control

@onready var title_label: Label = %TitleLabel

func _ready() -> void:
	title_label.text = "Lacebolla Rogue"

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/CharacterSelect.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
