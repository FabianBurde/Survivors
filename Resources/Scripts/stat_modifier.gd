# stat_modifier.gd
extends Resource
class_name StatModifier

enum ModifierType { FLAT, PERCENT }

@export var stat_name: String = ""       # e.g. "max_hp", "move_speed", "sword_damage"
@export var modifier_type: ModifierType = ModifierType.FLAT
@export var value: float = 0.0