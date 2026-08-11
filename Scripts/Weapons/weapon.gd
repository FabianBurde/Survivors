# weapon.gd
extends Node2D
class_name Weapon

@export var cooldown: float = 0.4
@export var icon: Texture2D
var cooldown_timer: float = 0.0

func _physics_process(delta: float) -> void:
    if cooldown_timer > 0.0:
        cooldown_timer -= delta

func try_attack() -> void:
    if cooldown_timer <= 0.0:
        attack()
        cooldown_timer = cooldown

func attack() -> void:
    pass  # override in subclasses

func get_cooldown_ratio() -> float:
    if cooldown <= 0.0:
        return 0.0
    return cooldown_timer / cooldown