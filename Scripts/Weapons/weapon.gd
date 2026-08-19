# weapon.gd (base class, expanded)
extends Node2D
class_name Weapon

@export var weapon_name: String = ""
@export var max_level: int = 10          # 10 for basic weapons, 15 for rare
@export var starting_element: String = ""  # "" = none, or "fire"/"lightning"/"water"/"earth"

var level: int = 1
@export var elements: Array[String] = []          # can hold multiple once acquired

var icon :Texture2D = null
@export var cooldown: float = 0.4
var cooldown_timer: float = 0.0

func _ready() -> void:
	if starting_element != "":
		elements.append(starting_element)
	

func _physics_process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta

func try_attack() -> void:
	if cooldown_timer <= 0.0:
		attack()
		cooldown_timer = cooldown

func get_cooldown_ratio() -> float:
	if cooldown <= 0.0:
		return 0.0
	return clamp(cooldown_timer / cooldown, 0.0, 1.0)

func attack() -> void:
	pass

func level_up() -> void:
	if level >= max_level:
		return
	level += 1
	_on_level_up()

func acquire_element(element_id: String) -> void:
	if not elements.has(element_id):
		elements.append(element_id)

func get_active_impact_effects() -> Array[ImpactEffect]:
	var effects: Array[ImpactEffect] = []
	for element_id in elements:
		var effect: ImpactEffect = ElementRegistry.get_effect_for(element_id)
		if effect != null:
			effects.append(effect)
	return effects

func _on_level_up() -> void:
	pass  # subclasses override to scale their own stats (damage, cooldown, etc.)
