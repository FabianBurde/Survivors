# sword_weapon.gd
extends Weapon

@export var base_damage: float = 15.0
@export var range: float = 80.0
@export var cone_angle_degrees: float = 90.0
@export var slash_sprite_frames: SpriteFrames

@onready var slash_sprite: AnimatedSprite2D = $SlashSprite

var cos_half_angle: float

func _ready() -> void:
	super._ready()
	cos_half_angle = cos(deg_to_rad(cone_angle_degrees / 2.0))
	slash_sprite.sprite_frames = slash_sprite_frames
	slash_sprite.visible = false

func attack() -> void:
	var player: CharacterBody2D = get_parent()
	var aim_dir: Vector2 = player.get_aim_direction()

	_play_slash_animation(aim_dir)
	_apply_damage(player, aim_dir)
	var debug_draw = player.get_node("SwordWeaponDebug")
	debug_draw.show_cone(aim_dir, range, cone_angle_degrees)	

func _play_slash_animation(aim_dir: Vector2) -> void:
	slash_sprite.position = position + aim_dir * (range * 0.5)  # position the slash sprite in front of the player

	slash_sprite.visible = true
	slash_sprite.rotation = aim_dir.angle() + PI/2
	slash_sprite.play("default")

func _on_slash_animation_finished() -> void:
	slash_sprite.visible = false

# sword_weapon.gd (update _apply_damage)
func _apply_damage(player: CharacterBody2D, aim_dir: Vector2) -> void:
	var final_damage: float = PlayerStats.apply_to("attack_damage", base_damage)
	var effects: Array[ImpactEffect] = get_active_impact_effects()

	var nearby: Array = CollisionManager.grid.get_nearby(player.position)
	for enemy in nearby:
		if enemy.is_dead:
			continue
		var to_enemy: Vector2 = enemy.position - player.position
		var dist_sq: float = to_enemy.length_squared()
		if dist_sq > range * range:
			continue
		var dot: float = aim_dir.dot(to_enemy.normalized())
		if dot >= cos_half_angle:
			if effects.is_empty():
				enemy.take_damage(final_damage,false,"Sword")
			else:
				for effect in effects:
					effect.on_impact(player.position, enemy, final_damage)
