# damage_number_manager.gd
extends Node

var number_scene: PackedScene = preload("res://Scenes/Sub/damage_number.tscn")

var pool: Array[DamageNumber] = []
var active_numbers: Array[DamageNumber] = []
var pool_size: int = 60   # numbers are short-lived, don't need many at once

func reset_for_level() -> void:
    _clear_pool()
    active_numbers.clear()
    _prewarm_pool()

func _clear_pool() -> void:
    for num in pool:
        if is_instance_valid(num):
            num.queue_free()
    pool.clear()

func _prewarm_pool() -> void:
    for i in range(pool_size):
        var num: DamageNumber = number_scene.instantiate()
        get_tree().current_scene.add_child(num)
        num.deactivate()
        pool.append(num)

func spawn_number(spawn_pos: Vector2, amount: float, is_crit: bool = false) -> void:
    var num: DamageNumber = _get_inactive_number()
    if num == null:
        return
    var offset: Vector2 = Vector2(randf_range(-10, 10), randf_range(-5, 5))
    num.activate(spawn_pos + offset, amount, is_crit)
    active_numbers.append(num)

func _get_inactive_number() -> DamageNumber:
    for num in pool:
        if not num.is_active:
            return num
    return null

func despawn_number(num: DamageNumber) -> void:
    num.deactivate()
    active_numbers.erase(num)