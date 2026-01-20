extends Node

const CLASS_WARRIOR := "warrior"
const CLASS_MAGE := "mage"
const CLASS_ROGUE := "rogue"

const BASE_STATS := {
	CLASS_WARRIOR: {"max_hp": 140, "move_speed": 95.0, "damage": 18, "attack_rate": 0.6},
	CLASS_MAGE: {"max_hp": 90, "move_speed": 90.0, "damage": 14, "attack_rate": 0.35},
	CLASS_ROGUE: {"max_hp": 100, "move_speed": 120.0, "damage": 12, "attack_rate": 0.45},
}

const PERK_POOL := [
	{"id": "max_hp", "name": "+ Vida", "desc": "+20 vida máxima", "value": 20},
	{"id": "damage", "name": "+ Daño", "desc": "+4 daño", "value": 4},
	{"id": "move_speed", "name": "+ Velocidad", "desc": "+10% velocidad", "value": 0.1},
	{"id": "attack_rate", "name": "+ Cadencia", "desc": "-10% tiempo de ataque", "value": -0.1},
	{"id": "crit", "name": "+ Crítico", "desc": "+5% prob. crítico", "value": 0.05},
]

var selected_class: String = CLASS_WARRIOR
var level: int = 1
var exp: int = 0
var exp_to_level: int = 5
var coins: int = 0
var keys: int = 0
var stats := {}
var crit_chance := 0.05

func _ready() -> void:
	reset_run()

func reset_run() -> void:
	level = 1
	exp = 0
	exp_to_level = 5
	coins = 0
	keys = 0
	crit_chance = 0.05
	stats = BASE_STATS[selected_class].duplicate(true)

func set_class(class_id: String) -> void:
	selected_class = class_id
	reset_run()

func add_exp(amount: int) -> bool:
	exp += amount
	if exp >= exp_to_level:
		exp -= exp_to_level
		level += 1
		exp_to_level = int(exp_to_level * 1.35) + 2
		return true
	return false

func get_random_perks() -> Array:
	var perks := PERK_POOL.duplicate(true)
	perks.shuffle()
	return perks.slice(0, 3)

func apply_perk(perk: Dictionary) -> void:
	match perk.id:
		"max_hp":
			stats["max_hp"] += perk.value
		"damage":
			stats["damage"] += perk.value
		"move_speed":
			stats["move_speed"] += stats["move_speed"] * perk.value
		"attack_rate":
			stats["attack_rate"] = max(0.1, stats["attack_rate"] + stats["attack_rate"] * perk.value)
		"crit":
			crit_chance += perk.value
