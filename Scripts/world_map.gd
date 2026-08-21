extends Node2D

@export var level_data: LevelData
@export var world_cam:Camera2D
@export var tile_map:TileMapLayer
@export var camera_speed: float = 2000.0
@export var camera_smoothing: float = 10.0

const CAMERA_MIN_POSITION := Vector2(-1.0, -1.0)
const CAMERA_MAX_POSITION := Vector2(4600.0, 3500.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_position: Vector2 = world_cam.position + dir * camera_speed * delta
	target_position.x = clampf(target_position.x, CAMERA_MIN_POSITION.x, CAMERA_MAX_POSITION.x)
	target_position.y = clampf(target_position.y, CAMERA_MIN_POSITION.y, CAMERA_MAX_POSITION.y)
	world_cam.position = world_cam.position.lerp(target_position, 1.0 - exp(-camera_smoothing * delta))


func start_level_01():
	SceneManager.start_level(level_data)


func _input(event: InputEvent) -> void:
	if event == InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			print("Mouse click at: %s" % event.position)