extends Node2D

@export var level_data: LevelData
@export var world_cam:Camera2D
@export var tile_map:TileMapLayer
@onready var grid_tiles_layer: TileMapLayer = $GridTilesLayer
@export var camera_speed: float = 12000.0
@export var camera_smoothing: float = 5.0

@onready var selection_overlay: TileMapLayer = $GridSelectionOverlay
@onready var tile_selection_lbl:Label = $UI/Control/TileSelectionLabel

var camera_zoom_index: int = 0

const CAMERA_MIN_POSITION := Vector2(-1.0, -1.0)
const CAMERA_MAX_POSITION := Vector2(4600.0, 3200.0)
const CAMERA_ZOOM_LEVELS := [Vector2(1.0, 1.0), Vector2(0.5, 0.5), Vector2(0.25, 0.25)]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_cam.zoom = CAMERA_ZOOM_LEVELS[camera_zoom_index]
	WorldMapManager.register_grid_layer(grid_tiles_layer)
	_apply_conquered_tile_visuals()
	WorldMapManager.selected_tiles.clear()
	WorldMapManager.refresh_selected_count()
	_refresh_visuals()


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
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_camera_zoom(camera_zoom_index + 1)
			get_viewport().set_input_as_handled()
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_camera_zoom(camera_zoom_index - 1)
			get_viewport().set_input_as_handled()
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			var local_pos: Vector2 = grid_tiles_layer.get_local_mouse_position()
			var coord: Vector2i = grid_tiles_layer.local_to_map(local_pos)
			_on_tile_clicked(coord)

func _set_camera_zoom(new_index: int) -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var viewport_center: Vector2 = get_viewport().get_visible_rect().size * 0.5
	var mouse_offset_from_center: Vector2 = mouse_position - viewport_center
	var world_mouse_before_zoom: Vector2 = world_cam.position + mouse_offset_from_center * world_cam.zoom

	camera_zoom_index = clampi(new_index, 0, CAMERA_ZOOM_LEVELS.size() - 1)
	var next_zoom: Vector2 = CAMERA_ZOOM_LEVELS[camera_zoom_index]
	world_cam.zoom = next_zoom

	var new_camera_position: Vector2 = world_mouse_before_zoom - mouse_offset_from_center * next_zoom
	new_camera_position.x = clampf(new_camera_position.x, CAMERA_MIN_POSITION.x, CAMERA_MAX_POSITION.x)
	new_camera_position.y = clampf(new_camera_position.y, CAMERA_MIN_POSITION.y, CAMERA_MAX_POSITION.y)
	world_cam.position = new_camera_position

func _on_tile_clicked(coord: Vector2i) -> void:
	if not WorldMapManager.tiles.has(coord):
		return  # clicked on empty space, not a valid tile
	var changed: bool = WorldMapManager.toggle_tile(coord)
	if changed:
		_refresh_visuals()

func _apply_conquered_tile_visuals() -> void:
	for coord in WorldMapManager.conquered_tiles:
		if WorldMapManager.tiles.has(coord):
			grid_tiles_layer.set_cell(coord, 1, Vector2i(0, 0), 2)

func _refresh_visuals() -> void:
	selection_overlay.clear()
	for coord in WorldMapManager.selected_tiles:
		selection_overlay.set_cell(coord, 1, Vector2i(0, 0),1)
	_apply_conquered_tile_visuals()
	WorldMapManager.refresh_selected_count()
	tile_selection_lbl.text = str(WorldMapManager.selected_tiles_count) + "/" + str(WorldMapManager.selected_tile_limit)
