# single_target_effect.gd
extends ImpactEffect
class_name SingleTargetEffect

func on_impact(hit_position: Vector2, hit_enemy: Enemy, damage: float, source_weapon_name: String = "Unknown") -> void:
	hit_enemy.take_damage(damage, source_weapon_name)
