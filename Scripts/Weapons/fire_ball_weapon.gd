# fireball_weapon.gd
extends Weapon

@export var base_damage: float = 25.0
@export var projectile_count: int = 2
@export var speed: float = 250.0
@export var radius: float = 10.0
@export var lifetime: float = 2.0
@export var pierce: int = 0
@export var impact_effects: Array[ImpactEffect] = [SingleTargetEffect.new()]

@export var sprite_frames: SpriteFrames

func _ready() -> void:
	super._ready()
	for element in elements:
		var effect: ImpactEffect = ElementRegistry.get_effect_for(element)
		if effect != null and not impact_effects.has(effect):
			impact_effects.append(effect)

func attack() -> void:
	var player: CharacterBody2D = get_parent()
	var dir: Vector2 = player.get_aim_direction()
	var final_damage: float = PlayerStats.apply_to("magic_damage", base_damage)
	#var offset: Vector2 = Vector2.RIGHT.rotated( * 2 * PI / projectile_count) * radius
	ProjectileManager.spawn_projectile(
		player.position, dir, speed, final_damage, radius, lifetime, pierce, impact_effects, sprite_frames, "Fireball",projectile_count, 20.0
	)
