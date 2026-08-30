extends Node

@onready var grid_layer: TileMapLayer  # we'll assign this differently, see note below


var tiles: Dictionary = {}            # Vector2i (hex coord) -> WorldMapTileData
var selected_tiles: Array[Vector2i] = []

func register_grid_layer(layer: TileMapLayer) -> void:
    grid_layer = layer
    _scan_painted_tiles()

func _scan_painted_tiles() -> void:
    tiles.clear()
    var used_cells: Array[Vector2i] = grid_layer.get_used_cells()
    for coord in used_cells:
        var tile_data := WorldMapTileData.new()
        tile_data.grid_pos = coord
        tiles[coord] = tile_data
    print(WorldMapManager.tiles.keys())

func get_tile(coord: Vector2i) -> WorldMapTileData:
    return tiles.get(coord, null)

func get_neighbors(coord: Vector2i) -> Array[Vector2i]:
    var all_neighbors: Array[Vector2i] = grid_layer.get_surrounding_cells(coord)
    var valid_neighbors: Array[Vector2i] = []
    for n in all_neighbors:
        if tiles.has(n):  # only count neighbors that are actually painted/valid tiles
            valid_neighbors.append(n)
    return valid_neighbors

# world_map_manager.gd (add)
func can_select(coord: Vector2i) -> bool:
    if not tiles.has(coord):
        return false
    if selected_tiles.has(coord):
        return false
    if selected_tiles.is_empty():
        return true
    for neighbor in get_neighbors(coord):
        if selected_tiles.has(neighbor):
            return true
    return false

func toggle_tile(coord: Vector2i) -> bool:
    if selected_tiles.has(coord):
        var would_remain: Array[Vector2i] = selected_tiles.duplicate()
        would_remain.erase(coord)
        if would_remain.is_empty() or _is_connected_group(would_remain):
            selected_tiles.erase(coord)
            return true
        return false
    elif can_select(coord):
        selected_tiles.append(coord)
        return true
    return false

func _is_connected_group(group: Array[Vector2i]) -> bool:
    if group.is_empty():
        return true
    var visited: Array[Vector2i] = []
    var to_visit: Array[Vector2i] = [group[0]]

    while not to_visit.is_empty():
        var current: Vector2i = to_visit.pop_back()
        if visited.has(current):
            continue
        visited.append(current)
        for neighbor in get_neighbors(current):
            if group.has(neighbor) and not visited.has(neighbor):
                to_visit.append(neighbor)

    return visited.size() == group.size()

