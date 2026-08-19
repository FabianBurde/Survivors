extends ImpactEffect
class_name LightningImpactEffect

@export var stun_duration: float = 4.0
@export var bounces: int = 1  # relative to the weapon's base hit damage

func on_impact(hit_position: Vector2, hit_enemy: Enemy, damage: float, source_weapon_name: String = "Unknown") -> void:
    hit_enemy.take_damage(damage, false, source_weapon_name)  # the normal hit damage still applies first
    hit_enemy.apply_status_effect("stunned", {
        "duration": stun_duration,
        "source_damage": damage, 
        "source_effect": self,
    })