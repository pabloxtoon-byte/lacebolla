extends Control

@onready var health_bar: ProgressBar = %HealthBar
@onready var coins_label: Label = %CoinsLabel
@onready var keys_label: Label = %KeysLabel
@onready var level_label: Label = %LevelLabel
@onready var message_label: Label = %MessageLabel
@onready var message_timer: Timer = $MessageTimer

func update_health(current: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current

func update_stats() -> void:
	coins_label.text = "Monedas: %d" % GameState.coins
	keys_label.text = "Llaves: %d" % GameState.keys
	level_label.text = "Nivel: %d" % GameState.level

func show_message(text: String) -> void:
	message_label.text = text
	message_label.visible = true
	message_timer.start()

func _on_message_timer_timeout() -> void:
	message_label.visible = false
