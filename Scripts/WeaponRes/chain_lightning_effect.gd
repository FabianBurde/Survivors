# chain_lightning_effect.gd
extends ImpactEffect
class_name ChainLightningEffect

@export var damage: float = 10.0
@export var chain_range: float = 100.0
@export var max_chains: int = 3

func on_impact(hit_position: Vector2, hit_enemy: Enemy) -> void:
    hit_enemy.take_damage(damage)
    # find nearest un-hit enemy within chain_range, recurse — we'll build this fully when you actually want lightning