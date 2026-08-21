extends ImpactEffect
class_name WaterImpactEffect

@export var slow_duration: float = 4.0
@export var stacks: int = 1  # relative to the weapon's base hit damage
var dmg : float = 2.0

func on_impact(hit_position: Vector2, hit_enemy: Enemy, damage: float, source_weapon_name: String = "Unknown") -> void:
    hit_enemy.take_damage(dmg, false, source_weapon_name)  # the normal hit damage still applies first
    hit_enemy.apply_status_effect("slowed", {
        "duration": slow_duration,
        "source_damage": dmg, 
        "source_effect": self,
    })