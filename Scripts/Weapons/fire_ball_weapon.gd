# fireball_weapon.gd
extends Weapon

@export var damage: float = 25.0
@export var speed: float = 250.0
@export var radius: float = 10.0
@export var lifetime: float = 2.0
@export var pierce: int = 0
@export var impact_effect: ImpactEffect = SingleTargetEffect.new()

@export var sprite_frames: SpriteFrames


func attack() -> void:
    var player: CharacterBody2D = get_parent()
    var dir: Vector2 = player.get_aim_direction()

    ProjectileManager.spawn_projectile(
        player.position, dir, speed, damage, radius, lifetime, pierce, impact_effect, sprite_frames, "Fireball"
    )