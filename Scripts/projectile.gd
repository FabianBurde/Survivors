# projectile.gd
extends Node2D
class_name Projectile

var velocity: Vector2 = Vector2.ZERO
var damage: float = 0.0
var radius: float = 6.0
var lifetime: float = 2.0
var pierce_count: int = 0  # how many enemies it can hit before disappearing, 0 = dies on first hit
var impact_effects: Array[ImpactEffect] = []
var source_weapon_name: String = "Unknown"

var is_active: bool = false
var life_timer: float = 0.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if not is_active:
		return

	position += velocity * delta

	life_timer -= delta
	if life_timer <= 0.0:
		ProjectileManager.despawn_projectile(self)

func activate(spawn_pos: Vector2, dir: Vector2, speed: float, p_damage: float, p_radius: float, p_lifetime: float, p_pierce: int, p_effects: Array[ImpactEffect], p_sprite_frames: SpriteFrames, p_source_weapon_name: String = "Unknown") -> void:
	position = spawn_pos
	velocity = dir * speed
	damage = p_damage
	radius = p_radius
	lifetime = p_lifetime
	life_timer = p_lifetime
	pierce_count = p_pierce
	impact_effects = p_effects
	source_weapon_name = p_source_weapon_name
	is_active = true
	visible = true

	sprite.sprite_frames = p_sprite_frames
	sprite.play("default")  # or whatever animation name you use
	sprite.rotation = dir.angle()  # so arrow visually points the direction it's flying

func deactivate() -> void:
	is_active = false
	visible = false
	position = Vector2(999999, 999999)

func on_hit_enemy(hit_enemy: Enemy) -> void:
	for effect in impact_effects:
		effect.on_impact(position, hit_enemy, damage, source_weapon_name)
	pierce_count -= 1
	if pierce_count < 0:
		ProjectileManager.despawn_projectile(self)
