extends CharacterBody2D

var hp = 100
var radius = 16.0

@export var iframe_duration = 1.0
var iframe_timer = 0.0
var is_invincible = false

const SPEED = 16000

@onready var weapons: Array[Weapon] = [
    $SwordWeapon,
    $BowWeapon,
    $FireBallWeapon,
]
var active_weapon_index: int = 0
var can_control: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.instance = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_aim_direction() -> Vector2:
	return (get_global_mouse_position() - global_position).normalized()

func _physics_process(delta: float) -> void:
	if is_invincible:
		iframe_timer -= delta
		modulate.a = 0.5 if int(iframe_timer * 10) % 2 == 0 else 1.0
		if iframe_timer <= 0.0:
			is_invincible = false
			modulate.a = 1.0
	if not can_control:
		velocity = Vector2.ZERO
		return
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * SPEED * delta
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if not can_control:
		return
	#print("Input event: %s" % event)
	if event.is_action_pressed("slot_1"):
		active_weapon_index = 0
	elif event.is_action_pressed("slot_2"):
		active_weapon_index = 1
	elif event.is_action_pressed("slot_3"):
		active_weapon_index = 2
	elif event.is_action_pressed("attack"):
		weapons[active_weapon_index].try_attack()


func take_damage(amount: float) -> void:
	if is_invincible:
		return
	is_invincible = true
	iframe_timer = iframe_duration
	hp -= amount
	print("Player took damage! HP: %d" % hp)
	if hp <= 0:
		die()

func die() -> void:
	print("Player has died!")
	LevelManager.report_player_death()