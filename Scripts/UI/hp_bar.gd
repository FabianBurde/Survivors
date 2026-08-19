# hp_bar.gd
extends Control

@onready var bar: TextureProgressBar = $PlayerHpBar
@onready var label: Label = $HpLabel

func _ready() -> void:
	# connect to whatever signal/source your player HP lives on
	PlayerGlobal.instance.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(PlayerGlobal.instance.hp, PlayerGlobal.instance.max_hp)

func _on_hp_changed(current: float, max_value: float) -> void:
	bar.max_value = max_value
	bar.value = current
	label.text = "%d / %d" % [current, max_value]
