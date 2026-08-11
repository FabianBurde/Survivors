# weapon_slot.gd
extends Control
class_name WeaponSlot

@onready var icon_rect: TextureRect = $Icon
@onready var cooldown_overlay: TextureProgressBar = $Cooldown
@onready var selection_highlight: Control = $Highlight

var weapon: Weapon = null

func set_weapon(p_weapon: Weapon) -> void:
	weapon = p_weapon

func set_icon(texture: Texture2D) -> void:
	icon_rect.texture = texture

func _process(delta: float) -> void:
	if weapon == null:
		return
	cooldown_overlay.value = weapon.get_cooldown_ratio()

func set_selected(is_selected: bool) -> void:
	selection_highlight.visible = is_selected
