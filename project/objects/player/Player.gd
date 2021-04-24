extends KinematicBody

const BulletScene = preload("res://objects/bullet/Bullet.tscn")

export(float) var gravity = 30
export(float) var sprint_multiplier = 2

var player_speed = 0
var player_max_speed = 10
var player_movement_direction = Vector3.FORWARD
var target_movement_vector = Vector2(0, 0)
var player_movement_acceleration = 1.0  # Speed at which the current vector moves towards the target
var player_turn_speed = 1.0  # Speed at which the player turns to face new direction (keyboard)
var player_look_speed = -0.005  # Sensitivity of mouse movement to player look


var _sprinting = false
var _current_fall_speed = 0


enum StrafeDirection{
	LEFT,
	RIGHT,
	NONE,
}
var strafe_direction = StrafeDirection.NONE

class MovementHelper:
	var forward = false
	var backward = false
	var left = false
	var right = false
	var sprinting = false
	
	var current_speed = 0
	var accelleration = 8
	var decelleration = -12
	var max_speed = 10
	var max_sprint_speed = 20
	
	func update_speed(delta):
		var speed_direction = accelleration
		if get_movement_direction() == Vector3.ZERO:
			speed_direction = decelleration
		
		current_speed += accelleration*delta*speed_direction
		
		#Make sure we don't go over max speed
		var current_max_speed = max_speed
		if sprinting:
			current_max_speed = max_sprint_speed
		
		current_speed = min(current_max_speed, current_speed)
		current_speed = max(0, current_speed)
	
	func get_movement_direction():
		
		#Do this the hard way
		if forward and backward or left and right:
			return Vector3.ZERO
		
		if forward and left:
			return Vector3.FORWARD.rotated(Vector3.UP, PI/4)
		elif forward and right:
			return Vector3.FORWARD.rotated(Vector3.UP, -PI/4)
		elif backward and left:
			return Vector3.BACK.rotated(Vector3.UP, -PI/4)
		elif backward and right:
			return Vector3.BACK.rotated(Vector3.UP, PI/4)
		
		if forward:
			return Vector3.FORWARD
		elif backward:
			return Vector3.BACK
		elif left:
			return Vector3.LEFT
		elif right:
			return Vector3.RIGHT
		else:
			return Vector3.ZERO

var _movement_helper = MovementHelper.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	set_physics_process(true)
	set_process_unhandled_key_input(true)
	set_process_unhandled_input(true)
	set_process_input(true)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _player_movement(delta):
	
	_movement_helper.update_speed(delta)
	var movement = transform.basis.x * _movement_helper.current_speed
	
	#Rotate movement to face the right direction
	var direction = _movement_helper.get_movement_direction()
	var rotation_angle = Vector3.FORWARD.angle_to(direction)
	
	#Fix for strafe right
	if sign(direction.x) == 1:
		rotation_angle = - rotation_angle
	
	movement = movement.rotated(Vector3.UP, rotation_angle)
	
	#Apply gravity
	_current_fall_speed -= gravity * delta
	movement.y = _current_fall_speed
	move_and_slide(movement)
	
	if get_slide_count():
		_current_fall_speed = 0
	

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
	new_bullet.transform.basis.x = transform.basis.x
	get_tree().root.add_child(new_bullet)
	

func _unhandled_key_input(event: InputEventKey):
	
	if event.is_action_pressed("player_pause"):
		get_tree().quit()
	elif event.is_action("player_forward"):
		_movement_helper.forward = event.pressed
	elif event.is_action("player_backwards"):
		_movement_helper.backward = event.pressed
	elif event.is_action("player_left"):
		_movement_helper.left = event.pressed
	elif event.is_action("player_right"):
		_movement_helper.right = event.pressed
	elif event.is_action("player_hold_sprint"):
		_movement_helper.sprinting = event.pressed
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
