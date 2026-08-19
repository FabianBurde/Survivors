extends ImpactEffect
class_name EarthImpactEffect

@export var stun_duration: float = 1.0
@export var slow_duration: float = 2.0

func on_impact(hit_position: Vector2, hit_enemy: Enemy, damage: float, source_weapon_name: String = "Unknown") -> void:
    hit_enemy.take_damage(damage, false, source_weapon_name)  # the normal hit damage still applies first
    hit_enemy.apply_status_effect("stunned", {
        "duration": stun_duration,
        "source_damage": damage, 
        "source_effect": self,
    })
    hit_enemy.apply_status_effect("slowed", {
        "duration": slow_duration,
        "source_damage": damage,
        "source_effect": self,
    })