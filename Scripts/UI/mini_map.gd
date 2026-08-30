# minimap.gd
extends Control

@export var minimap_scale: float = 0.02   # tune this - shrinks world-space distances to fit the minimap
@export var chunk_hex_size: float = 12.0  # visual radius of each drawn chunk hexagon, in minimap pixels

var main_scene: Node = null

func _ready() -> void:
    main_scene = get_tree().current_scene

func _process(delta: float) -> void:
    queue_redraw()

func _draw() -> void:
    if main_scene == null or not "chunk_centers" in main_scene:
        return
    if main_scene.chunk_centers.is_empty():
        return

    var center_of_minimap: Vector2 = size / 2.0

    for relative_coord in main_scene.chunk_centers.keys():
        var chunk_hex_coord: Vector2i = main_scene.chunk_centers[relative_coord]
        var world_pos: Vector2 = main_scene.gameplay_tilemap.map_to_local(chunk_hex_coord)
        var minimap_pos: Vector2 = center_of_minimap + world_pos * minimap_scale
        _draw_hex_outline(minimap_pos, chunk_hex_size, Color.WHITE)

    if PlayerGlobal.instance != null:
        var player_world_pos: Vector2 = PlayerGlobal.instance.position
        var player_minimap_pos: Vector2 = center_of_minimap + player_world_pos * minimap_scale
        draw_circle(player_minimap_pos, 3.0, Color.RED)

func _draw_hex_outline(center: Vector2, radius: float, color: Color) -> void:
    var points: PackedVector2Array = []
    for i in range(7):
        var angle: float = deg_to_rad(60 * i - 30)  # -30 offset for pointy-top hex, adjust if flat-top
        points.append(center + Vector2(cos(angle), sin(angle)) * radius)
    draw_polyline(points, color, 1.5)