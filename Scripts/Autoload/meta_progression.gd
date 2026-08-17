# meta_progression.gd
extends Node

const SAVE_FILE: String = "meta_progression.json"

var gold: int = 0
var node_levels: Dictionary = {}   # id (String) -> purchase count (int)

var tree: UpgradeTree = preload("res://Resources/Progression/upgrade_tree_01.tres")  # adjust path

func _ready() -> void:
    load_progress()
    if gold == 0 and node_levels.is_empty():
        gold = 500  # starting gold for a fresh save
        save_progress()

func get_level(node_id: String) -> int:
    return node_levels.get(node_id, 0)

func is_maxed(node: UpgradeNode) -> bool:
    return get_level(node.id) >= node.max_purchases

func can_purchase(node: UpgradeNode) -> bool:
    if is_maxed(node):
        return false
    var current_level: int = get_level(node.id)
    if gold < node.get_cost_for_level(current_level):
        return false
    for prereq_id in node.prerequisite_ids:
        if get_level(prereq_id) <= 0:  # prerequisite must be owned at least once
            return false
    return true

func purchase(node: UpgradeNode) -> bool:
    if not can_purchase(node):
        return false
    var current_level: int = get_level(node.id)
    gold -= node.get_cost_for_level(current_level)
    node_levels[node.id] = current_level + 1
    save_progress()
    return true

func get_all_modifiers() -> Array[StatModifier]:
    var result: Array[StatModifier] = []
    for node in tree.nodes:
        var level: int = get_level(node.id)
        for i in range(level):
            result.append_array(node.modifiers)  # applied once per purchased level
    return result

func save_progress() -> void:
    SaveManager.save_data(SAVE_FILE, {
        "gold": gold,
        "node_levels": node_levels
    })

func load_progress() -> void:
    var data: Dictionary = SaveManager.load_data(SAVE_FILE)
    gold = data.get("gold", 0)
    node_levels = data.get("node_levels", {})