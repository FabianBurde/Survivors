# sword_debug_draw.gd
extends Node2D

var show_debug: bool = true  # toggle this off once you trust it
var current_range: float = 0.0
var current_angle_rad: float = 0.0
var current_dir: Vector2 = Vector2.RIGHT
var is_showing: bool = false

func show_cone(dir: Vector2, p_range: float, cone_angle_degrees: float) -> void:
    current_dir = dir
    current_range = p_range
    current_angle_rad = deg_to_rad(cone_angle_degrees)
    is_showing = true
    queue_redraw()

func _draw() -> void:
    if not show_debug or not is_showing:
        return

    var points: PackedVector2Array = []
    points.append(Vector2.ZERO)  # cone origin (player position, since this node should be child of Player)

    var half_angle = current_angle_rad / 2.0
    var segments = 16
    for i in range(segments + 1):
        var t = float(i) / float(segments)
        var angle = current_dir.angle() - half_angle + t * current_angle_rad
        var point = Vector2(cos(angle), sin(angle)) * current_range
        points.append(point)

    draw_colored_polygon(points, Color(1.0, 0.2, 0.2, 0.35))  # translucent red