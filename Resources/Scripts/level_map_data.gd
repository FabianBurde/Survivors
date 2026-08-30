# level_map_data.gd
extends Resource
class_name LevelMapData

var chunk_hex_coords: Array[Vector2i] = []      # relative hex coords, re-centered around origin
var tile_types: Dictionary = {}                 # hex_coord -> tile_type String

static func build_from_selection(selected: Array[Vector2i], world_tiles: Dictionary) -> LevelMapData:
	var data := LevelMapData.new()

	# Re-center: shift all selected coords so their average sits near origin
	var center: Vector2i = _compute_center(selected)

	for hex_coord in selected:
		var relative_coord: Vector2i = hex_coord - center
		data.chunk_hex_coords.append(relative_coord)
		var tile_data: WorldMapTileData = world_tiles.get(hex_coord)
		data.tile_types[relative_coord] = tile_data.tile_type if tile_data != null else "plains"

	return data

static func _compute_center(coords: Array[Vector2i]) -> Vector2i:
	var sum := Vector2i.ZERO
	for c in coords:
		sum += c
	return Vector2i(sum.x / coords.size(), sum.y / coords.size())
