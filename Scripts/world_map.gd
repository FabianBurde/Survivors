extends Node2D

@export var level_data: LevelData
@export var world_cam:Camera2D
@export var tile_map:TileMapLayer
@onready var grid_tiles_layer: TileMapLayer = $GridTilesLayer
@export var camera_speed: float = 12000.0
@export var camera_smoothing: float = 5.0

@onready var selection_overlay: TileMapLayer = $GridSelectionOverlay

const CAMERA_MIN_POSITION := Vector2(-1.0, -1.0)
const CAMERA_MAX_POSITION := Vector2(4600.0, 3500.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorldMapManager.register_grid_layer(grid_tiles_layer)
	WorldMapManager.selected_tiles.clear()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_position: Vector2 = world_cam.position + dir * camera_speed * delta
	target_position.x = clampf(target_position.x, CAMERA_MIN_POSITION.x, CAMERA_MAX_POSITION.x)
	target_position.y = clampf(target_position.y, CAMERA_MIN_POSITION.y, CAMERA_MAX_POSITION.y)
	world_cam.position = world_cam.position.lerp(target_position, 1.0 - exp(-camera_smoothing * delta))


func start_level_01():
	SceneManager.start_level(level_data)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos: Vector2 = grid_tiles_layer.get_local_mouse_position()
		var coord: Vector2i = grid_tiles_layer.local_to_map(local_pos)
		_on_tile_clicked(coord)

func _on_tile_clicked(coord: Vector2i) -> void:
	if not WorldMapManager.tiles.has(coord):
		return  # clicked on empty space, not a valid tile
	var changed: bool = WorldMapManager.toggle_tile(coord)
	if changed:
		_refresh_visuals()

func _refresh_visuals() -> void:
	selection_overlay.clear()
	for coord in WorldMapManager.selected_tiles:
		selection_overlay.set_cell(coord, 1, Vector2i(0, 0),1)
