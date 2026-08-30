# scene_manager.gd (autoload, name it "SceneManager")
extends Node

var current_level_data: LevelData = null
var last_run_result: Dictionary = {}  # e.g. {"won": true, "xp_gained": 120}
var current_level_map_data: LevelMapData = null

func start_level(level_data: LevelData) -> void:
	current_level_data = level_data
	current_level_map_data = LevelMapData.build_from_selection(
		WorldMapManager.selected_tiles,
		WorldMapManager.tiles
	)
	get_tree().change_scene_to_packed(level_data.level_scene)

func return_to_world_map(result: Dictionary) -> void:
	last_run_result = result
	get_tree().change_scene_to_file("res://Scenes/world_map.tscn")
