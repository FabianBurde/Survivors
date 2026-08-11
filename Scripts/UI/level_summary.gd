extends Control

@onready var title_label: RichTextLabel = $MarginContainer/VBoxContainer/Title
@onready var summary_container: VBoxContainer = $MarginContainer/VBoxContainer/MarginContainer/ColorRect/SummaryContainer
@onready var confirm_button: TextureButton = $MarginContainer/VBoxContainer/TextureButton

func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_pressed)

func set_summary(result: Dictionary) -> void:
	_clear_summary()
	title_label.text = "_ Level Complete _" if (result.get("won", false) == true)  else "_ Level Over _"

	var lines: Array = []
	lines.append("Level: %s" % result.get("level_name", "Unknown"))
	if result.has("total_kills"):
		lines.append("Total Kills: %s" % str(result["total_kills"]))
	if result.has("xp_collected"):
		lines.append("XP Collected: %s" % str(result["xp_collected"]))
	if result.has("levels_gained"):
		lines.append("Levels Gained: %s" % str(result["levels_gained"]))
	if result.has("kills_by_weapon"):
		lines.append("")
		lines.append("Kills by Weapon:")
		for weapon_name in result["kills_by_weapon"].keys():
			lines.append("  %s: %s" % [weapon_name, str(result["kills_by_weapon"][weapon_name])])

	for i in range(lines.size()):
		var label = Label.new()
		label.text = lines[i]
		label.modulate = Color(1, 1, 1, 0)
		summary_container.add_child(label)

		var delay_time: float = i * 1.0
		var tween = create_tween()
		tween.tween_property(label, "modulate:a", 1.0, delay_time + 0.3)

func _clear_summary() -> void:
	for child in summary_container.get_children():
		child.queue_free()

func _on_confirm_pressed() -> void:
	hide()
	SceneManager.return_to_world_map(SceneManager.last_run_result)
