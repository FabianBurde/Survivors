extends Node2D

@export var player: CharacterBody2D
@export var camera: Camera2D
@export var base_marker:Marker2D
@export var base_arrow:Sprite2D
@export var spawns:Node2D
@export var fps_lbl:Label

var arrow_active = false
var update_camera_intervall = 0.1
var cam_time = 0.0
var smoothing_speed = 15.0

@onready var level_summary: Control = $UI/Control/LevelSummary
@export var init_timer: Timer

@onready var gameplay_tilemap: TileMapLayer = $TileLayer/GameplayTileMap
@onready var walls_layer: TileMapLayer = $TileLayer/WallsTileMap
@onready var hex_generator:HexMapUtils = $HexGenerator

const CHUNK_RADIUS:int = 128
var chunk_centers: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_for_level()
	gameplay_tilemap.clear()
	_build_gameplay_map()

#func _build_gameplay_map() -> void:
#	var map_data: LevelMapData = SceneManager.current_level_map_data
#	if map_data == null:
#		return
#	for hex_coord in map_data.chunk_hex_coords:
#		var tile_type: String = map_data.tile_types.get(hex_coord, "plains")
#		_stamp_chunk(hex_coord, tile_type)

# main_scene.gd - TEMPORARY: single chunk only, ignore multi-chunk arrangement for now
func _build_gameplay_map() -> void:
	var map_data: LevelMapData = SceneManager.current_level_map_data
	if map_data == null or map_data.chunk_hex_coords.is_empty():
		return
	chunk_centers = HexMapUtils.compute_chunk_centers(
		map_data.chunk_hex_coords, CHUNK_RADIUS, gameplay_tilemap
	)

	var playable_cells: Dictionary = {}  # Vector2i -> true, used as a Set

	for relative_coord in map_data.chunk_hex_coords:
		var center: Vector2i = chunk_centers[relative_coord]
		var region: Array[Vector2i] = HexMapUtils.get_filled_region(center, CHUNK_RADIUS, gameplay_tilemap)
		for coord in region:
			gameplay_tilemap.set_cell(coord, 0, Vector2i(1, 1))
			playable_cells[coord] = true
	_build_border(playable_cells)
	
func _build_border(playable_cells: Dictionary) -> void:
	var border_cells: Dictionary = {}  # dedup, since a coord can be found as "outside neighbor" from multiple cells

	for coord in playable_cells.keys():
		for neighbor in gameplay_tilemap.get_surrounding_cells(coord):
			if not playable_cells.has(neighbor):
				border_cells[neighbor] = true

	for coord in border_cells.keys():
		walls_layer.set_cell(coord, 0, Vector2i(3, 0))

### TODO DELETE LATER
func _stamp_chunk(chunk_center: Vector2i, tile_type: String) -> void:
	var region: Array[Vector2i] = HexMapUtils.get_filled_region(chunk_center, CHUNK_RADIUS, gameplay_tilemap)
	for coord in region:
		gameplay_tilemap.set_cell(coord, 0, Vector2i(1, 1))

func reset_for_level():
	RunUpgrades.reset()
	PlayerStats.refresh()
	EnemyManager.reset_for_level()
	ProjectileManager.reset_for_level()
	XpOrbManager.reset_for_level()
	DamageNumberManager.reset_for_level()
	level_summary.hide()
	LevelManager.level_won.connect(_on_level_end)
	LevelManager.level_lost.connect(_on_level_end)
	LevelManager.start_level(SceneManager.current_level_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if init_timer.is_stopped() == false:
		player.position.x += 100.0 * delta
	cam_time +=  delta
	fps_lbl.text = "fps: " + str(Engine.get_frames_per_second())
	#print(cam_time)
	if arrow_active:
		handle_arrow()
	else:
		base_arrow.visible = false
	if cam_time >= update_camera_intervall:
		cam_time = 0.0
		handle_camera(delta)


func handle_camera(delta: float) -> void:
	camera.global_position = camera.global_position.lerp(player.global_position, smoothing_speed * delta)
	if player.global_position.distance_to(base_marker.global_position) > 1000:
		arrow_active = true
	else:
		arrow_active = false

### TODO this was an early try to show an arrow pointing offscreen
### can be deleted
func handle_arrow():
	var viewport_size = get_viewport_rect().size
	var center = viewport_size / 2.0
	var margin = 48.0  # keep the arrow this far inside the true edge

	var dir = (base_marker.global_position - player.global_position).normalized()
	if dir == Vector2.ZERO:
		base_arrow.visible = false
		return

	var bounds = center - Vector2(margin, margin)

	# how far along `dir` until we hit the horizontal edge, and the vertical edge
	var scale_x = (bounds.x / abs(dir.x)) if dir.x != 0.0 else INF
	var scale_y = (bounds.y / abs(dir.y)) if dir.y != 0.0 else INF
	var scale = min(scale_x, scale_y)  # whichever edge we hit first

	base_arrow.position = center + dir * scale
	base_arrow.rotation = dir.angle()
	base_arrow.visible = true

func _on_level_end() -> void:
	player.can_control = false
	level_summary.set_summary(SceneManager.last_run_result)
	level_summary.show()

func _debug_return_to_world_map() -> void:
	LevelManager._win_level()
	SceneManager.return_to_world_map({})
