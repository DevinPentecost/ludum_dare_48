extends KinematicBody

const BulletScene = preload("res://objects/bullet/Bullet.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player_speed = 0
var player_max_speed = 10
var player_movement_direction = Vector3.FORWARD
var target_movement_vector = Vector2(0, 0)
var player_movement_acceleration = 1.0  # Speed at which the current vector moves towards the target
var player_turn_speed = 1.0  # Speed at which the player turns to face new direction (keyboard)
var player_look_speed = -0.005  # Sensitivity of mouse movement to player look


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	set_physics_process(true)
	set_process_unhandled_key_input(true)
	set_process_unhandled_input(true)
	set_process_input(true)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _player_movement(delta):
	var movement = transform.basis.x * player_speed
	move_and_slide(movement)

func _physics_process(delta):
	_player_movement(delta)

func _movement_towards_target():
	pass


func _handle_player_look(mouse_event : InputEventMouseMotion):
	
	#Figure out how much the player looked (horizontal)
	var horizontal_look = mouse_event.relative.x * player_look_speed
	rotate_y(horizontal_look)

func _handle_player_fire():
	$Camera/ViewModel.fire()
	
	#Spawn a bullet
	var new_bullet = BulletScene.instance()
	new_bullet.transform.origin = $BulletSpawner.global_transform.origin
	get_tree().root.add_child(new_bullet)
	

func _unhandled_key_input(event: InputEventKey):
	
	if event.is_action_pressed("player_pause"):
		get_tree().quit()
	elif event.is_action("player_forward"):
		if event.pressed:
			player_speed = player_max_speed
		else:
			player_speed = 0
	elif event.is_action("player_backwards"):
		if event.pressed:
			player_speed = -player_max_speed
		else:
			player_speed = 0
	elif event.is_action("player_fire"):
		if event.pressed:
			_handle_player_fire()

func _unhandled_input(event):
	
	#Is this a mouse look?
	if event is InputEventMouseMotion:
		
		#We need to adjust the player look based on the event
		_handle_player_look(event)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			_handle_player_fire()
