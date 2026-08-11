# aoe_explosion_effect.gd
extends ImpactEffect
class_name AoeExplosionEffect

@export var explosion_radius: float = 80.0

func on_impact(hit_position: Vector2, hit_enemy: Enemy, damage: float, source_weapon_name: String = "Unknown") -> void:
    var nearby: Array = CollisionManager.grid.get_nearby(hit_position)
    for enemy in nearby:
        if enemy.is_dead:
            continue
        var dist_sq = (enemy.position - hit_position).length_squared()
        if dist_sq <= explosion_radius * explosion_radius:
            enemy.take_damage(damage)