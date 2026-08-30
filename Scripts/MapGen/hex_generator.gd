# hex_map_utils.gd
class_name HexMapUtils
extends Node
# --- Region filling ---

static func get_filled_region(center: Vector2i, radius: int, layer: TileMapLayer) -> Array[Vector2i]:
    var visited: Dictionary = {center: 0}  # coord -> distance from center
    var queue: Array[Vector2i] = [center]
    var result: Array[Vector2i] = [center]

    while not queue.is_empty():
        var current: Vector2i = queue.pop_front()
        var current_dist: int = visited[current]

        if current_dist >= radius:
            continue

        for neighbor in layer.get_surrounding_cells(current):
            if not visited.has(neighbor):
                visited[neighbor] = current_dist + 1
                result.append(neighbor)
                queue.append(neighbor)

    return result

# --- Chunk placement ---

static func compute_chunk_centers(relative_coords: Array[Vector2i], radius: int, layer: TileMapLayer) -> Dictionary:
    var centers: Dictionary = {}
    if relative_coords.is_empty():
        return centers

    var visited: Array[Vector2i] = [relative_coords[0]]
    centers[relative_coords[0]] = Vector2i.ZERO
    var queue: Array[Vector2i] = [relative_coords[0]]

    while not queue.is_empty():
        var current: Vector2i = queue.pop_front()
        var current_center: Vector2i = centers[current]

        for neighbor in layer.get_surrounding_cells(current):
            if not relative_coords.has(neighbor) or visited.has(neighbor):
                continue

            var direction: int = _find_direction(current, neighbor, layer)
            var scaled_center: Vector2i = _walk_direction(current_center, direction, radius * 2, layer)

            centers[neighbor] = scaled_center
            visited.append(neighbor)
            queue.append(neighbor)

    return centers

static func _find_direction(from_coord: Vector2i, to_coord: Vector2i, layer: TileMapLayer) -> int:
    for dir in range(6):
        if layer.get_neighbor_cell(from_coord, dir) == to_coord:
            return dir
    return 0

static func _walk_direction(start: Vector2i, direction: int, steps: int, layer: TileMapLayer) -> Vector2i:
    var current: Vector2i = start
    for i in range(steps):
        current = layer.get_neighbor_cell(current, direction)
    return current