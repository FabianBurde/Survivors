extends Node2D

@export var level_data: LevelData
@export var world_cam:Camera2D
@export var tile_map:TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_level_01():
	SceneManager.start_level(level_data)


func _input(event: InputEvent) -> void:
	var dir: Vector2 = Input.get_vector("move_left","move_right","move_up","move_down")
	world_cam.position += dir * 100

	if event == InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			print("Mouse click at: %s" % event.position)