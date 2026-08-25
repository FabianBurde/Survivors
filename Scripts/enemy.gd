class_name Enemy
extends Node2D

var radius = 12.0
var max_hp = 20
var hp = 20
var speed = 100.0
var contact_damage = 5
var is_dead = false
var is_active:bool = false
var last_damage_source: String = "Unknown"
var status_effects: Dictionary = {}

const DEBUG_CIRCLE_SCENE: PackedScene = preload("res://Scenes/Debug/debug_circle_draw.tscn")
##BaseEXP
@export var xp_value: float = 5.0

@onready var player: CharacterBody2D = get_node("/root/MainScene/Player")
@onready var sprite = $SPR
@onready var status_indicator: Label = $StatusIndicator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func debug_apply_burn() -> void:
	apply_status_effect("burning", {
		"tick_damage": 3.0,
		"tick_timer": 1.0,
		"tick_interval": 1.0,
		"duration": 5.0
	})

func _physics_process(delta: float) -> void:
	if not is_active or is_dead:
		return
	_tick_status_effects(delta)
	# ... existing movement, but movement speed reads a "slowed" multiplier from status_effects
	var dir = (PlayerGlobal.instance.position - position).normalized()
	var speed_mult: float = 1.0
	if status_effects.has("slowed"):
		speed_mult = status_effects["slowed"].get("speed_multiplier", 1.0)
	if status_effects.has("stunned"):
		speed_mult = 0.0
	position += dir * speed * speed_mult * delta


func _get_speed_multiplier() -> float:
	if status_effects.has("stunned"):
		return 0.0
	if status_effects.has("slowed"):
		return status_effects["slowed"].get("speed_multiplier", 1.0)
	return 1.0

func take_damage(amount: float,from_status_effect: bool = false, source_weapon_name: String = "Unknown") -> void:
	if not is_active:
		return
	last_damage_source = source_weapon_name
	hp -= amount
	DamageNumberManager.spawn_number(position, amount)
	var dmg_tween = create_tween()
	dmg_tween.tween_property(sprite, "modulate", Color(1, 0, 0), 0.1)
	dmg_tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.1)
	if hp <= 0:
		die()

func _tick_status_effects(delta: float) -> void:
	var expired: Array = []

	for effect_id in status_effects.keys():
		var effect: Dictionary = status_effects[effect_id]

		# Damage-over-time ticking (used by fire, later)
		if effect.has("tick_damage"):
			effect["tick_timer"] = effect.get("tick_timer", 0.0) - delta
			if effect["tick_timer"] <= 0.0:
				take_damage(effect["tick_damage"], true)
				effect["tick_timer"] = effect.get("tick_interval", 1.0)

		# Stacking effects decay instead of expiring on a flat duration (used by water, later)
		if effect.has("stacks"):
			effect["decay_timer"] = effect.get("decay_timer", 0.0) - delta
			if effect["decay_timer"] <= 0.0 and effect["stacks"] > 0:
				effect["stacks"] -= 1
				effect["decay_timer"] = effect.get("decay_interval", 1.0)
			if effect["stacks"] <= 0:
				expired.append(effect_id)
			continue  # skip the generic duration check below for stacking effects

		# Generic duration countdown (slow, stun, vulnerable, etc.)
		effect["duration"] = effect.get("duration", 0.0) - delta
		if effect["duration"] <= 0.0:
			expired.append(effect_id)

	for effect_id in expired:
		status_effects.erase(effect_id)

	_refresh_status_visual()

func _trigger_fire_explosion() -> void:
	var burn_data: Dictionary = status_effects["burning"]
	var source_effect: FireImpactEffect = burn_data.get("source_effect", null)
	if source_effect == null:
		return
	
	var explosion_damage: float = burn_data.get("source_damage", 0.0) * source_effect.explosion_damage_multiplier
	var explosion_radius: float = source_effect.explosion_radius
	
	_spawn_debug_circle(explosion_radius)

	var nearby: Array = CollisionManager.grid.get_nearby(position)
	for enemy in nearby:
		if enemy == self or enemy.is_dead:
			continue
		var dist_sq: float = (enemy.position - position).length_squared()
		if dist_sq <= source_effect.explosion_radius * source_effect.explosion_radius:
			enemy.take_damage(explosion_damage, true)
			enemy.apply_status_effect("burning", burn_data.duplicate())

func _spawn_debug_circle(radius: float) -> void:
	var circle: DebugCircleDraw = DEBUG_CIRCLE_SCENE.instantiate()
	get_tree().current_scene.add_child(circle)
	circle.global_position = global_position
	circle.show_circle(radius, 0.6)
	# simple self-cleanup after the debug display finishes
	var timer: SceneTreeTimer = get_tree().create_timer(0.6)
	timer.timeout.connect(func(): circle.queue_free())

func apply_status_effect(effect_id: String, data: Dictionary) -> void:
	status_effects[effect_id] = data
	_refresh_status_visual()

func _refresh_status_visual() -> void:
	if status_effects.is_empty():
		status_indicator.text = ""
		return

	var symbols: Array[String] = []
	for effect_id in status_effects.keys():
		symbols.append(_get_status_symbol(effect_id))
	status_indicator.text = " ".join(symbols)

func _get_status_symbol(effect_id: String) -> String:
	match effect_id:
		"burning": return "🔥"
		"stunned": return "⚡"
		"slowed": return "💧"
		"vulnerable": return "🪨"
		_: return "?"


func die() -> void:
	is_dead = true
	if status_effects.has("burning"):
		_trigger_fire_explosion()
	LevelManager.record_enemy_killed(last_damage_source)
	XpOrbManager.spawn_orb(position, xp_value)
	EnemyManager.despawn_enemy(self)
	#await sprite.play("die").finished
	deactivate()

func activate(spawn_pos: Vector2, type_data: EnemyTypeData) -> void:
	position = spawn_pos
	max_hp = type_data.max_hp
	hp = max_hp
	speed = type_data.speed
	contact_damage = type_data.contact_damage
	xp_value = type_data.xp_value
	radius = type_data.radius
	sprite.sprite_frames = type_data.sprite_frames
	sprite.play("run")

	is_dead = false
	is_active = true
	visible = true
	status_effects.clear()
	_refresh_status_visual()

func deactivate() -> void:
	is_active = false
	visible = false
	position = Vector2(999999, 999999)
	status_effects.clear()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_key"):
		debug_apply_burn()
