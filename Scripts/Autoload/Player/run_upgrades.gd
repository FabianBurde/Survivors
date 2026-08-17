# run_upgrades.gd (autoload, name it "RunUpgrades")
extends Node

var active_modifiers: Array[StatModifier] = []

func add_modifier(mod: StatModifier) -> void:
    active_modifiers.append(mod)
    PlayerStats.refresh()

func reset() -> void:
    active_modifiers.clear()