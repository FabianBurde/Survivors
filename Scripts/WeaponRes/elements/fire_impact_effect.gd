# fire_impact_effect.gd
extends ImpactEffect
class_name FireImpactEffect

@export var tick_damage: float = 3.0
@export var tick_interval: float = 1.0
@export var burn_duration: float = 4.0
@export var explosion_radius: float = 60.0
@export var explosion_damage_multiplier: float = 1.5  # relative to the weapon's base hit damage

func on_impact(hit_position: Vector2, hit_enemy: Enemy, damage: float, source_weapon_name: String = "Unknown") -> void:
    hit_enemy.take_damage(damage, false, source_weapon_name)  # the normal hit damage still applies first
    hit_enemy.apply_status_effect("burning", {
        "tick_damage": tick_damage,
        "tick_timer": tick_interval,
        "tick_interval": tick_interval,
        "duration": burn_duration,
        "source_damage": damage,  # remembered so explosion scales off the original hit
        "source_effect": self,
    })