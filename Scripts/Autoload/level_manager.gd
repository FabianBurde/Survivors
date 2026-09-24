# level_manager.gd (autoload, name it "LevelManager")
extends Node

signal time_extended(new_remaining: float)
signal level_won
signal level_lost

var time_remaining: float = 0.0
var total_duration: float = 0.0
var is_level_active: bool = false

var total_kills: int = 0
var xp_collected: float = 0.0
var start_player_level: int = 1
var kills_by_weapon: Dictionary = {}
var enemies_killed_name: Dictionary = {}

func _ready() -> void:
	pass
	# runs once MainScene loads; pull config from whatever level was selected
	#if SceneManager.current_level_data != null:
	#    start_level(SceneManager.current_level_data)

func start_level(level_data:Array[LevelMapData]) -> void:
	reset_level_stats()
	start_player_level = PlayerXP.current_level
	total_duration = 120.0
	time_remaining = total_duration
	await get_tree().create_timer(1.2).timeout
	is_level_active = true
	CollisionManager.enable()

func reset_level_stats() -> void:
	total_kills = 0
	xp_collected = 0.0
	start_player_level = PlayerXP.current_level
	kills_by_weapon = {}
	enemies_killed_name = {}

func _physics_process(delta: float) -> void:
	if not is_level_active:
		return

	time_remaining -= delta
	if time_remaining <= 0.0:
		_win_level()

func extend_time(amount: float) -> void:
	if not is_level_active:
		return
	time_remaining += amount
	time_extended.emit(time_remaining)

func record_enemy_killed(weapon_name: String = "Unknown", enemy_name: String = "Unknown") -> void:
	total_kills += 1
	kills_by_weapon[weapon_name] = kills_by_weapon.get(weapon_name, 0) + 1
	enemies_killed_name[enemy_name] = enemies_killed_name.get(enemy_name, 0) + 1

func add_xp_collected(amount: float) -> void:
	xp_collected += amount

func _get_level_summary() -> Dictionary:
	return {
		"won": false,
		"level_name": "DemoLevel1",#SceneManager.current_level_data.level_name if SceneManager.current_level_data != null else "Unknown",
		"total_kills": total_kills,
		"xp_collected": xp_collected,
		"levels_gained": max(PlayerXP.current_level - start_player_level, 0),
		"kills_by_weapon": kills_by_weapon,
		"enemies_killed_name": enemies_killed_name,
	}

func _win_level() -> void:
	is_level_active = false
	CollisionManager.disable()
	var result = _get_level_summary()
	result["won"] = true
	SceneManager.last_run_result = result
	level_won.emit()

func report_player_death() -> void:
	if not is_level_active:
		return
	is_level_active = false
	CollisionManager.disable()
	var result = _get_level_summary()
	result["won"] = false
	SceneManager.last_run_result = result
	level_lost.emit()
