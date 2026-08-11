# enemy_manager.gd
extends Node

@export var min_spawn_interval: float = 0.3
@export var max_spawn_interval: float = 2.0 
var enemy_scene: PackedScene = preload("res://Scenes/enemy_01.tscn")

var pool: Array[Enemy] = []       # all enemies that exist, ever
var enemies: Array[Enemy] = []    # currently active enemies only

var pool_size: int = 300  # start conservative, tune later

var spawn_interval: float = 1.0
var spawn_timer: float = 0.0
var spawn_radius: float = 400.0



func reset_for_level() -> void:
	_clear_pool()
	enemies.clear()
	_prewarm_pool()

func _clear_pool() -> void:
	for enemy in pool:
		if is_instance_valid(enemy):
			enemy.queue_free()
	pool.clear()

func _prewarm_pool() -> void:
	for i in range(pool_size):
		var enemy: Enemy = enemy_scene.instantiate()
		get_tree().current_scene.add_child.call_deferred(enemy)
		enemy.deactivate()
		pool.append(enemy)

func _physics_process(delta: float) -> void:
	spawn_timer += delta
	var current_interval: float = _get_scaled_spawn_interval()
	if spawn_timer >= current_interval:
		spawn_timer = 0.0
		spawn_enemy()

func _get_scaled_spawn_interval() -> float:
	if not LevelManager.is_level_active:
		return spawn_interval
	
	var elapsed: float = LevelManager.total_duration - LevelManager.time_remaining
	var progress: float = clamp(elapsed / LevelManager.total_duration, 0.0, 1.0)
	
	var curve: Curve = SceneManager.current_level_data.difficulty_ramp_curve
	if curve != null:
		var t: float = curve.sample(progress)  # 0 = slow end, 1 = fast end
		return lerp(max_spawn_interval, min_spawn_interval, t)
	
	return spawn_interval


func spawn_enemy() -> void:
	if Player.instance == null:
		return

	var enemy: Enemy = _get_inactive_enemy()
	if enemy == null:
		return  # pool exhausted, see note below

	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	var spawn_pos = Player.instance.position + offset

	enemy.activate(spawn_pos)
	enemies.append(enemy)

func _get_inactive_enemy() -> Enemy:
	for enemy in pool:
		if not enemy.is_active:
			return enemy
	return null

func despawn_enemy(enemy: Enemy) -> void:
	enemy.deactivate()
	enemies.erase(enemy)
