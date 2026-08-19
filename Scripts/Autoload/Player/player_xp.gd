# player_xp.gd (autoload, name it "PlayerXP")
extends Node

signal xp_changed(current_xp: float, xp_to_next_level: float)
signal leveled_up(new_level: int)

var current_xp: float = 0.0
var xp_to_next_level: float = 20.0
var current_level: int = 1

func add_xp(amount: float) -> void:
    current_xp += amount
    if current_xp >= xp_to_next_level:
        _level_up()
    xp_changed.emit(current_xp, xp_to_next_level)

func _level_up() -> void:
    current_xp -= xp_to_next_level
    current_level += 1
    xp_to_next_level *= 1.2  # each level requires a bit more, tune to taste
    leveled_up.emit(current_level)
    xp_changed.emit(current_xp, xp_to_next_level)