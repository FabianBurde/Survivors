# damage_number.gd
extends Node2D
class_name DamageNumber

@onready var label: Label = $Label

var is_active: bool = false
var lifetime: float = 0.8
var life_timer: float = 0.0
var float_speed: float = 40.0
var fade_start_ratio: float = 0.5  # start fading after 50% of lifetime

func _physics_process(delta: float) -> void:
    if not is_active:
        return

    position.y -= float_speed * delta

    life_timer -= delta
    var progress: float = 1.0 - (life_timer / lifetime)

    if progress >= fade_start_ratio:
        var fade_progress: float = (progress - fade_start_ratio) / (1.0 - fade_start_ratio)
        label.modulate.a = 1.0 - fade_progress

    if life_timer <= 0.0:
        DamageNumberManager.despawn_number(self)

func activate(spawn_pos: Vector2, amount: float, is_crit: bool = false) -> void:
    position = spawn_pos
    life_timer = lifetime
    label.text = str(int(amount))
    label.modulate = Color.WHITE if not is_crit else Color.YELLOW
    label.modulate.a = 1.0
    is_active = true
    visible = true

func deactivate() -> void:
    is_active = false
    visible = false
    position = Vector2(999999, 999999)