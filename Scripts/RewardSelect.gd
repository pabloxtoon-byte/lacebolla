extends Control

signal perk_selected(perk)

@onready var buttons: Array[Button] = [
	%PerkButton1,
	%PerkButton2,
	%PerkButton3
]

var current_perks: Array = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_rewards(perks: Array) -> void:
	current_perks = perks
	for i in range(buttons.size()):
		var perk: Dictionary = perks[i]
		buttons[i].text = "%s\n%s" % [perk.name, perk.desc]
	visible = true
	get_tree().paused = true

func _on_perk_pressed(index: int) -> void:
	var perk: Dictionary = current_perks[index]
	visible = false
	get_tree().paused = false
	emit_signal("perk_selected", perk)

func _on_perk_button_1_pressed() -> void:
	_on_perk_pressed(0)

func _on_perk_button_2_pressed() -> void:
	_on_perk_pressed(1)

func _on_perk_button_3_pressed() -> void:
	_on_perk_pressed(2)
