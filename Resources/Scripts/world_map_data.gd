# world_map_tile_data.gd
extends Resource
class_name WorldMapTileData

enum TileType {
	PLAINS,
	FOREST,
	MOUNTAIN,
	BEACH,
	DUNGEON,
	TOWN,
	ARENA
}

@export var grid_pos: Vector2i = Vector2i.ZERO
@export var tile_type: TileType = TileType.PLAINS
@export var base_difficulty: float = 1.0