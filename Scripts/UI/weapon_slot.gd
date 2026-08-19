# weapon_slot.gd
extends Control
class_name WeaponSlot

@onready var icon_rect: TextureRect = $Icon
@onready var cooldown_overlay: TextureProgressBar = $Cooldown
@onready var selection_highlight: Control = $Highlight
@onready var elemnts_label: Label = $ElementsLabel

var weapon: Weapon = null

func set_weapon(p_weapon: Weapon) -> void:
	weapon = p_weapon

func set_weapon_elements(p_elements: Array[String]) -> void:
	if weapon == null:
		return
	var elements_text: String = ""
	for element_id in p_elements:
		elements_text += element_id.capitalize() + " "
	elements_text = elements_text.strip_edges()
	elemnts_label.text = elements_text

func set_icon(texture: Texture2D) -> void:
	icon_rect.texture = texture

func _process(delta: float) -> void:
	if weapon == null:
		return
	cooldown_overlay.value = weapon.get_cooldown_ratio()

func set_selected(is_selected: bool) -> void:
	selection_highlight.visible = is_selected
