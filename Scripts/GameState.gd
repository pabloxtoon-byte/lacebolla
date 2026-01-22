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

const ITEM_POOL := [
	"Poción pequeña",
	"Bomba de humo",
	"Flecha afilada",
	"Anillo oxidado",
	"Amuleto tenue",
	"Libro antiguo",
	"Daga curva",
	"Runa chispeante",
	"Escama dura",
	"Talismán oscuro",
]

var selected_class: String = CLASS_WARRIOR
var level: int = 1
var xp: int = 0
var exp_to_level: int = 5
var coins: int = 0
var keys: int = 0
var stats := {}
var crit_chance := 0.05
var inventory: Array[String] = []

func _ready() -> void:
	reset_run()

func reset_run() -> void:
	level = 1
	xp = 0
	exp_to_level = 5
	coins = 0
	keys = 0
	crit_chance = 0.05
	stats = BASE_STATS[selected_class].duplicate(true)
	inventory = []
	for i in range(10):
		inventory.append("")

func set_class(class_id: String) -> void:
	selected_class = class_id
	reset_run()

func add_exp(amount: int) -> bool:
	xp += amount
	if xp >= exp_to_level:
		xp -= exp_to_level
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

func get_random_item() -> String:
	return ITEM_POOL.pick_random()

func add_item(item_name: String) -> bool:
	for i in range(inventory.size()):
		if inventory[i] == "":
			inventory[i] = item_name
			return true
	return false
