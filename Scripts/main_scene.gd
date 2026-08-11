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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EnemyManager.reset_for_level()
	ProjectileManager.reset_for_level()
	XpOrbManager.reset_for_level()
	level_summary.hide()
	LevelManager.level_won.connect(_on_level_end)
	LevelManager.level_lost.connect(_on_level_end)
	LevelManager.start_level(SceneManager.current_level_data)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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

func spawn_enemies():
	var spawn_points = spawns.get_children()
	for spawn_point in spawn_points:
		var enemy_scene = preload("res://Scenes/enemy_01.tscn")
		var enemy_instance = enemy_scene.instantiate()
		enemy_instance.global_position = spawn_point.global_position
		add_child(enemy_instance)

func _on_level_end() -> void:
	player.can_control = false
	level_summary.set_summary(SceneManager.last_run_result)
	level_summary.show()
