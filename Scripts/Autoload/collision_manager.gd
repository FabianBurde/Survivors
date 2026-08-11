# collision_manager.gd
extends Node

var grid: SpatialGrid = SpatialGrid.new(64.0)


var separation_interval: float = 0.05  # ~20Hz
var separation_timer: float = 0.0
var separation_strength: float = 0.5   # how strongly enemies push apart, 0-1
var is_enabled: bool = false

func _ready() -> void:
	set_physics_process(false)

func enable() -> void:
	is_enabled = true
	set_physics_process(true)

func disable() -> void:
	is_enabled = false
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if not is_enabled:
		return

	_rebuild_grid()
	_check_player_enemy_collisions()
	_check_projectile_enemy_collisions()
	_check_player_orb_pickups()
	separation_timer += delta
	if separation_timer >= separation_interval:
		separation_timer = 0.0
		_apply_enemy_separation()

func _apply_enemy_separation() -> void:
	for enemy in EnemyManager.enemies:
		if enemy.is_dead:
			continue

		var nearby: Array = grid.get_nearby(enemy.position)
		var push := Vector2.ZERO

		for other in nearby:
			if other == enemy or other.is_dead:
				continue

			var diff = enemy.position - other.position
			var dist_sq = diff.length_squared()
			var min_dist = enemy.radius + other.radius

			if dist_sq < min_dist * min_dist and dist_sq > 0.0001:
				var dist = sqrt(dist_sq)
				var overlap_amount = min_dist - dist
				push += (diff / dist) * overlap_amount  # normalize manually, we already have dist

		enemy.position += push * separation_strength

func _rebuild_grid() -> void:
	grid.clear()
	for enemy in EnemyManager.enemies:
		grid.insert(enemy)

func _check_player_enemy_collisions() -> void:
	if Player.instance == null:
		return

	var nearby: Array = grid.get_nearby(Player.instance.position)
	for enemy in nearby:
		if enemy.is_dead:
			continue
		if _circles_overlap(Player.instance.position, Player.instance.radius, enemy.position, enemy.radius):
			Player.instance.take_damage(enemy.contact_damage)
			#enemy.take_damage(9999)  # for testing, instantly kill the enemy

func _check_projectile_enemy_collisions() -> void:
	for proj in ProjectileManager.active_projectiles:
		if not proj.is_active:
			continue

		var nearby: Array = grid.get_nearby(proj.position)
		for enemy in nearby:
			if enemy.is_dead:
				continue

			if _circles_overlap(proj.position, proj.radius, enemy.position, enemy.radius):
				proj.on_hit_enemy(enemy)
				if not proj.is_active:
					break  # projectile died this hit (pierce exhausted), stop checking more enemies

func _check_player_orb_pickups() -> void:
	if Player.instance == null:
		return

	var pickup_radius: float = 20.0  # how close counts as "collected", separate from magnet range

	for orb in XpOrbManager.active_orbs:
		if not orb.is_active:
			continue

		var dist_sq: float = (Player.instance.position - orb.position).length_squared()
		if dist_sq <= pickup_radius * pickup_radius:
			PlayerXP.add_xp(orb.xp_value)
			LevelManager.add_xp_collected(orb.xp_value)
			orb.deactivate()

func _circles_overlap(pos_a: Vector2, r_a: float, pos_b: Vector2, r_b: float) -> bool:
	var d = pos_a - pos_b
	var dist_sq = d.x * d.x + d.y * d.y
	var r_sum = r_a + r_b
	return dist_sq <= r_sum * r_sum
	return dist_sq <= r_sum * r_sum
