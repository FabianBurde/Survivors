# xp_bar.gd
extends Control

@onready var progress_bar: TextureProgressBar = $EXPProgress
@onready var level_label: Label = $LevelLabel

func _ready() -> void:
	PlayerXP.xp_changed.connect(_on_xp_changed)
	PlayerXP.leveled_up.connect(_on_leveled_up)
	_on_xp_changed(PlayerXP.current_xp, PlayerXP.xp_to_next_level)  # set initial state

func _on_xp_changed(current: float, needed: float) -> void:
	progress_bar.max_value = needed
	progress_bar.value = current
	level_label.text = "Lv. " + str(PlayerXP.current_level)

func _on_leveled_up(new_level: int) -> void:
	level_label.text = "Lv. " + str(new_level)
