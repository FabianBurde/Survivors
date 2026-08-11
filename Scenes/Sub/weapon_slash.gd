extends Area2D
### DELETE LATER
var damage = 10
## TODO Implement Multihit
#var slash_ani_packed = preload("res://Scenes/Sub/weapon_slash.tscn")
@onready var cooldown_timer = $Cooldown
@onready var animation_spr = $Ani
var on_cooldown = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group("CanHit") and not on_cooldown:
			animation_spr.visible = true
			animation_spr.global_position = area.global_position
			animation_spr.play("default")
			on_cooldown = true
			cooldown_timer.start()
			await animation_spr.animation_finished
			area.take_damage(damage)
			animation_spr.visible = false

func _on_Cooldown_timeout() -> void:
	on_cooldown = false
