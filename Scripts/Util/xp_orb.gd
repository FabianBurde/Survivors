# xp_orb.gd
extends Node2D
class_name XpOrb

@export var pickup_radius: float = 60.0   # distance at which magnet kicks in
@export var magnet_speed: float = 300.0

var xp_value: float = 0.0
var is_active: bool = false
var is_magnetized: bool = false

func _physics_process(delta: float) -> void:
    if not is_active:
        return

    if PlayerGlobal.instance == null:
        return

    var to_player: Vector2 = PlayerGlobal.instance.position - position
    var dist_sq: float = to_player.length_squared()

    if not is_magnetized and dist_sq <= pickup_radius * pickup_radius:
        is_magnetized = true

    if is_magnetized:
        var dir: Vector2 = to_player.normalized()
        position += dir * magnet_speed * delta

func activate(spawn_pos: Vector2, p_xp_value: float) -> void:
    position = spawn_pos
    xp_value = p_xp_value
    is_active = true
    is_magnetized = false
    visible = true

func deactivate() -> void:
    is_active = false
    visible = false
    position = Vector2(999999, 999999)