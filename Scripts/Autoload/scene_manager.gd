# scene_manager.gd (autoload, name it "SceneManager")
extends Node

var current_level_data: LevelData = null
var last_run_result: Dictionary = {}  # e.g. {"won": true, "xp_gained": 120}

func start_level(level_data: LevelData) -> void:
    current_level_data = level_data
    get_tree().change_scene_to_packed(level_data.level_scene)

func return_to_world_map(result: Dictionary) -> void:
    last_run_result = result
    get_tree().change_scene_to_file("res://world_map.tscn")