# SpatialGrid.gd
class_name SpatialGrid


var cell_size: float
var cells: Dictionary = {} # Vector2i -> Array[entity_id]

func _init(p_cell_size: float):
    cell_size = p_cell_size

func clear():
    cells.clear()

func _cell_coord(pos: Vector2) -> Vector2i:
    return Vector2i(floori(pos.x / cell_size), floori(pos.y / cell_size))

func insert(enemy: Enemy):
    var coord = _cell_coord(enemy.position)
    if not cells.has(coord):
        cells[coord] = []
    cells[coord].append(enemy)

func get_nearby(pos: Vector2) -> Array:
    var coord = _cell_coord(pos)
    var result = []
    for dx in [-1, 0, 1]:
        for dy in [-1, 0, 1]:
            var neighbor = coord + Vector2i(dx, dy)
            if cells.has(neighbor):
                result.append_array(cells[neighbor])
    return result