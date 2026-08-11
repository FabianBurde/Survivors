# impact_effect.gd
extends Resource
class_name ImpactEffect

func on_impact(hit_position: Vector2, hit_enemy: Enemy, damage: float, source_weapon_name: String = "Unknown") -> void:
    pass  # override in subclasses