# upgrade_node.gd
extends Resource
class_name UpgradeNode

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var base_cost: int = 100
@export var cost_increase_per_level: int = 50   # each purchase gets more expensive
@export var max_purchases: int = 1                # 1 = old "buy once" behavior, 5 = repeatable
@export var tier: int = 1
@export var prerequisite_ids: Array[String] = []
@export var modifiers: Array[StatModifier] = []   # applied ONCE PER purchase level
@export var tree_position: Vector2 = Vector2.ZERO

func get_cost_for_level(current_level: int) -> int:
    return base_cost + (cost_increase_per_level * current_level)