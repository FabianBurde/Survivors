# xp_orb_manager.gd
extends Node

var orb_scene: PackedScene = preload("res://Scenes/Sub/xp_orb.tscn")

var pool: Array[XpOrb] = []
var active_orbs: Array[XpOrb] = []

var pool_size: int = 300

func reset_for_level() -> void:
	_clear_pool()
	active_orbs.clear()
	_prewarm_pool()

func _clear_pool():
	for orb in pool:
		if is_instance_valid(orb):
			orb.queue_free()
	pool.clear()

func _prewarm_pool() -> void:
	for i in range(pool_size):
		var orb: XpOrb = orb_scene.instantiate()
		get_tree().current_scene.add_child.call_deferred(orb)
		orb.deactivate()
		pool.append(orb)

func spawn_orb(spawn_pos: Vector2, xp_value: float) -> void:
	var orb: XpOrb = _get_inactive_orb()
	if orb == null:
		return
	orb.activate(spawn_pos, xp_value)
	active_orbs.append(orb)

func _get_inactive_orb() -> XpOrb:
	for orb in pool:
		if not orb.is_active:
			return orb
	return null

func despawn_orb(orb: XpOrb) -> void:
	orb.deactivate()
	active_orbs.erase(orb)