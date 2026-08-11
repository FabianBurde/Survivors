# projectile_manager.gd
extends Node

var projectile_scene: PackedScene = preload("res://Scenes/Sub/projectile.tscn")

var pool: Array[Projectile] = []
var active_projectiles: Array[Projectile] = []

var pool_size: int = 200

func reset_for_level() -> void:
	_clear_pool()
	active_projectiles.clear()
	_prewarm_pool()

func _clear_pool():
	for projectile in pool:
		if is_instance_valid(projectile):
			projectile.queue_free()
	pool.clear()

func _prewarm_pool() -> void:
	for i in range(pool_size):
		var proj: Projectile = projectile_scene.instantiate()
		get_tree().current_scene.add_child.call_deferred(proj)
		proj.deactivate()
		pool.append(proj)

func spawn_projectile(spawn_pos: Vector2, dir: Vector2, speed: float, damage: float, radius: float, lifetime: float, pierce: int, effect: ImpactEffect, spr_frames:SpriteFrames, source_weapon_name: String = "Unknown") -> void:
	var proj: Projectile = _get_inactive_projectile()
	if proj == null:
		return
	proj.activate(spawn_pos, dir, speed, damage, radius, lifetime, pierce, effect, spr_frames, source_weapon_name)
	active_projectiles.append(proj)

func _get_inactive_projectile() -> Projectile:
	for proj in pool:
		if not proj.is_active:
			return proj
	return null

func despawn_projectile(proj: Projectile) -> void:
	proj.deactivate()
	active_projectiles.erase(proj)
