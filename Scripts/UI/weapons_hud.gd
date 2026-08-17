extends HBoxContainer

@onready var slots: Array[WeaponSlot] = [
	$WeaponSlot1,
	$WeaponSlot2,
	$WeaponSlot3
]

func _ready() -> void:
	var player = PlayerGlobal.instance
	for i in range(slots.size()):
		slots[i].set_weapon(player.weapons[i])

func _process(delta: float) -> void:
	var player = PlayerGlobal.instance
	for i in range(slots.size()):
		slots[i].set_weapon(player.weapons[i])
		slots[i].set_icon(player.weapons[i].icon)
		slots[i].set_selected(i == player.active_weapon_index)
