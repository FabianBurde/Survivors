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

##BaseEXP
@export var xp_value: float = 5.0

@onready var player: CharacterBody2D = get_node("/root/MainScene/Player")
@onready var spr = $SPR


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if not is_active or is_dead:
		return
	# basic "move toward player" — we'll refine this later
	var dir = (PlayerGlobal.instance.position - position).normalized()
	position += dir * speed * delta
	spr.play("run")

func take_damage(amount: float, source_weapon_name: String = "Unknown") -> void:
	if not is_active:
		return
	last_damage_source = source_weapon_name
	hp -= amount
	DamageNumberManager.spawn_number(position, amount)
	var dmg_tween = create_tween()
	dmg_tween.tween_property(spr, "modulate", Color(1, 0, 0), 0.1)
	dmg_tween.tween_property(spr, "modulate", Color(1, 1, 1), 0.1)
	if hp <= 0:
		die()

func die() -> void:
	is_dead = true
	LevelManager.record_enemy_killed(last_damage_source)
	XpOrbManager.spawn_orb(position, xp_value)
	EnemyManager.despawn_enemy(self)
	#await spr.play("die").finished
	deactivate()

func activate(spawn_pos: Vector2) -> void:
	position = spawn_pos
	hp = max_hp
	is_dead = false
	is_active = true
	visible = true

func deactivate() -> void:
	is_active = false
	visible = false
	position = Vector2(999999, 999999)
