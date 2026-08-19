# bow_weapon.gd
extends Weapon

@export var base_damage: float = 12.0
@export var speed: float = 400.0
@export var radius: float = 5.0
@export var lifetime: float = 1.5
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
	var final_damage: float = PlayerStats.apply_to("attack_damage", base_damage)
	ProjectileManager.spawn_projectile(
		player.position, dir, speed, final_damage, radius, lifetime, pierce, impact_effects, sprite_frames, "Bow"
	)
