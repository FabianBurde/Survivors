# debug_circle_draw.gd
extends Node2D
class_name DebugCircleDraw

var show_debug: bool = true
var current_radius: float = 0.0
var is_showing: bool = false
var display_timer: float = 0.0

func show_circle(p_radius: float, duration: float = 0.5) -> void:
    current_radius = p_radius
    is_showing = true
    display_timer = duration
    queue_redraw()

func _process(delta: float) -> void:
    if is_showing:
        display_timer -= delta
        if display_timer <= 0.0:
            is_showing = false
        queue_redraw()

func _draw() -> void:
    if not show_debug or not is_showing:
        return
    draw_circle(Vector2.ZERO, current_radius, Color(1.0, 0.5, 0.0, 0.25))  # translucent orange fill
    draw_arc(Vector2.ZERO, current_radius, 0, TAU, 32, Color(1.0, 0.5, 0.0, 0.8), 2.0)  # solid outline