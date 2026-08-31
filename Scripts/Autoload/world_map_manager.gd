extends Node

@onready var grid_layer: TileMapLayer  # we'll assign this differently, see note below


var tiles: Dictionary = {}            # Vector2i (hex coord) -> WorldMapTileData
var selected_tiles: Array[Vector2i] = []
const HOME_TILE_COORD: Vector2i = Vector2i(3, 35)
var conquered_tiles: Array[Vector2i] = [HOME_TILE_COORD]
var selected_tile_limit: int = 1
var selected_tiles_count:int = 0

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

func _is_adjacent_to_home_or_conquered(coord: Vector2i) -> bool:
    if coord == HOME_TILE_COORD:
        return true
    for neighbor in get_neighbors(coord):
        if neighbor == HOME_TILE_COORD or conquered_tiles.has(neighbor) or selected_tiles.has(neighbor):
            return true
    return false

func can_select(coord: Vector2i) -> bool:
    if not tiles.has(coord):
        return false
    if selected_tiles.has(coord):
        return false
    if conquered_tiles.has(coord):
        return false
    if selected_tiles.size() >= selected_tile_limit:
        return false
    return _is_adjacent_to_home_or_conquered(coord)

func refresh_selected_count() -> void:
    selected_tiles_count = selected_tiles.size()

func toggle_tile(coord: Vector2i) -> bool:
    if selected_tiles.has(coord):
        var would_remain: Array[Vector2i] = selected_tiles.duplicate()
        would_remain.erase(coord)
        if would_remain.is_empty() or _is_connected_group(would_remain):
            selected_tiles.erase(coord)
            refresh_selected_count()
            return true
        return false
    elif can_select(coord):
        selected_tiles.append(coord)
        refresh_selected_count()
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

