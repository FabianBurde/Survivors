# level_data.gd
extends Resource
class_name LevelData

@export var level_name: String = "Level 1"
@export var survive_duration: float = 180.0  # seconds
@export var difficulty_ramp_curve: Curve  # optional, controls spawn rate scaling over time
@export var level_scene: PackedScene  # which gameplay scene to load