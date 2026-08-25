# enemy_manager.gd
extends Node

var basic_enemy_type_zone1: EnemyTypeData = preload("res://Resources/Enemies/basic_enemy_type_zone1_01.tres")
var big_enemy_type_zone1: EnemyTypeData = preload("res://Resources/Enemies/big_enemy_type_zone1_01.tres")
var basic_enemy_type_zone1_02: EnemyTypeData = preload("res://Resources/Enemies/basic_enemy_type_zone1_02.tres")

var current_basic_type: EnemyTypeData
var milestones_triggered: Dictionary = {}

@export var min_spawn_interval: float = 0.3
@export var max_spawn_interval: float = 2.0 
var enemy_scene: PackedScene = preload("res://Scenes/enemy.tscn")

var pool: Array[Enemy] = []       # all enemies that exist, ever
var enemies: Array[Enemy] = []    # currently active enemies only

var pool_size: int = 300  # start conservative, tune later

var spawn_interval: float = 1.0
var spawn_timer: float = 0.0
var spawn_radius: float = 400.0
var horde_size: int = 8
var horde_tick_interval: float = 50.0
var horde_timer: float = 0.0
var big_spawn_interval: float = 30.0
var big_spawn_timer: float = 0.0


func reset_for_level() -> void:
	_clear_pool()
	enemies.clear()
	_prewarm_pool()
	current_basic_type = basic_enemy_type_zone1
	big_spawn_timer = 0.0
	milestones_triggered.clear()

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
	if not LevelManager.is_level_active:
		return
	var elapsed: float = LevelManager.total_duration - LevelManager.time_remaining
	_check_milestones(elapsed)
	spawn_timer += delta
	horde_timer += delta
	big_spawn_timer += delta
	var current_interval: float = _get_scaled_spawn_interval()
	if spawn_timer >= current_interval:
		spawn_timer = 0.0
		spawn_enemy(current_basic_type)
	if horde_timer >= horde_tick_interval:
		horde_timer = 0.0
		print("spawning HORDE")
		for i in range(horde_size):
			spawn_enemy(current_basic_type,true)
	if big_spawn_timer >= big_spawn_interval:
		big_spawn_timer = 0.0
		spawn_enemy(big_enemy_type_zone1)
		print("spawning BIG ENEMY")

func _check_milestones(elapsed: float) -> void:
	if elapsed >= 60.0 and not milestones_triggered.get("basic_upgrade", false):
		milestones_triggered["basic_upgrade"] = true
		current_basic_type = basic_enemy_type_zone1_02

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


func spawn_enemy(type_data: EnemyTypeData, is_horde: bool = false) -> void:
	if PlayerGlobal.instance == null:
		return

	var enemy: Enemy = _get_inactive_enemy()
	if enemy == null:
		return  # pool exhausted, see note below
	var angle = randf() * TAU
	if is_horde:
		angle += randf_range(-PI / 8, PI / 8)  # slight variation for horde members
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	var spawn_pos = PlayerGlobal.instance.position + offset

	enemy.activate(spawn_pos, type_data)
	enemies.append(enemy)

func _get_inactive_enemy() -> Enemy:
	for enemy in pool:
		if not enemy.is_active:
			return enemy
	return null

func despawn_enemy(enemy: Enemy) -> void:
	enemy.deactivate()
	enemies.erase(enemy)
