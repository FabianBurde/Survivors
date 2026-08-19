extends Node

var _effects: Dictionary = {
	"fire": preload("res://Resources/Elements/fire_impact_effect.tres"),
	"lightning": preload("res://Resources/Elements/lightning_impact_effect.tres"),
	"water": preload("res://Resources/Elements/water_impact_effect.tres"),
	"earth": preload("res://Resources/Elements/earth_impact_effect.tres"),
}

func get_effect_for(element_id: String) -> ImpactEffect:
	return _effects.get(element_id, null)
