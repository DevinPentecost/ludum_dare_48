extends KinematicBody
class_name Player
signal fired
signal health_changed(new_health)
signal player_died


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

var player_health = 100
var player_dead = false

var _current_fall_speed = 0

onready var collider = $CollisionShape
onready var target = $Target


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
	var sprinting = true
	
	var current_speed = 0
	var accelleration = 8
	var decelleration = -8
	var max_speed = 10
	var max_sprint_speed = 20
	var last_movement_direction = Vector3.ZERO
	var decellerate = true
	
	func update_speed(delta):
		var speed_direction = accelleration
		if decellerate:
			speed_direction = decelleration
		
		current_speed += accelleration*delta*speed_direction
		
		#Make sure we don't go over max speed
		var current_max_speed = max_speed
		if sprinting:
			current_max_speed = max_sprint_speed
		
		current_speed = min(current_max_speed, current_speed)
		current_speed = max(0, current_speed)
	
	func get_movement_direction():
		decellerate = false
		#Do this the hard way
		if forward and backward or left and right:
			return last_movement_direction
		
		if forward and left:
			last_movement_direction = Vector3.FORWARD.rotated(Vector3.UP, PI/4)
			return last_movement_direction
		elif forward and right:
			last_movement_direction = Vector3.FORWARD.rotated(Vector3.UP, -PI/4)
			return last_movement_direction
		elif backward and left:
			last_movement_direction = Vector3.BACK.rotated(Vector3.UP, -PI/4)
			return last_movement_direction
		elif backward and right:
			last_movement_direction = Vector3.BACK.rotated(Vector3.UP, PI/4)
			return last_movement_direction
		
		if forward:
			last_movement_direction = Vector3.FORWARD
			return last_movement_direction
		elif backward:
			last_movement_direction = Vector3.BACK
			return last_movement_direction
		elif left:
			last_movement_direction = Vector3.LEFT
			return last_movement_direction
		elif right:
			last_movement_direction = Vector3.RIGHT
			return last_movement_direction
		else:
			decellerate = true
			return last_movement_direction
		

var _movement_helper = MovementHelper.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	set_physics_process(true)
	set_process_unhandled_key_input(true)
	set_process_unhandled_input(true)
	set_process_input(true)


func _player_movement(delta):
	if player_dead: return
	
	_movement_helper.update_speed(delta)
	var movement = transform.basis.x * _movement_helper.current_speed
	
	#Rotate movement to face the right direction
	var direction = _movement_helper.get_movement_direction()
	var rotation_angle = Vector3.FORWARD.angle_to(direction)
	
	#Fix for strafe right
	if sign(direction.x) == 1:
		rotation_angle = - rotation_angle
	
	movement = movement.rotated(Vector3.UP, rotation_angle)
	move_and_slide(movement)
	
func _player_fall(delta):
	#Apply gravity
	_current_fall_speed -= gravity * delta
	var movement = Vector3.ZERO
	movement.y = _current_fall_speed
	move_and_slide(movement)
	
	if get_slide_count():
		_current_fall_speed = 0

func _physics_process(delta):
	_player_movement(delta)
	_player_fall(delta)

func _movement_towards_target():
	pass

func take_damage(damage):
	player_health -= damage
	emit_signal("health_changed", player_health)
	$AudioStreamPlayer.play_ow()
	$Camera/ViewModel.hurt()
	if player_health < 0:
		die()

func die():
	if player_dead: return
	
	#First, move the collision shape up (so we fall)
	collider.transform.origin.y += $Camera.transform.origin.y - 1
	
	#Add a horrible red screen or something
	$Camera/ViewModel.die()
	
	$AudioStreamPlayer.play_die()
	player_dead = true
	emit_signal("player_died")
	

func _handle_player_look(mouse_event : InputEventMouseMotion):
	if player_dead: return
	
	#Figure out how much the player looked (horizontal)
	var horizontal_look = mouse_event.relative.x * player_look_speed
	rotate_y(horizontal_look)

func _handle_player_fire():
	if player_dead: return
	
	$Camera/ViewModel.fire()
	
	
	$Camera/PawR/paws/AnimationPlayer.stop()
	$Camera/PawR/paws/AnimationPlayer.play("bark")
	$Camera/PawR/paws/AnimationPlayer.queue("idle-loop")
	$Camera/PawL/paws/AnimationPlayer.stop()
	$Camera/PawL/paws/AnimationPlayer.play("bark")
	$Camera/PawL/paws/AnimationPlayer.queue("idle-loop")
	
	#Spawn a bullet
	var new_bullet = BulletScene.instance()
	get_tree().root.add_child(new_bullet)
	new_bullet.transform.origin = $BulletSpawner.global_transform.origin
	new_bullet.shoot_at($BulletSpawner/shoot_target)
	emit_signal("fired")
	

func _unhandled_key_input(event: InputEventKey):
	
	if event.is_action_pressed("player_pause"):
		if not player_dead: die()
		else:
			_restart()
	elif event.is_action("player_forward"):
		_movement_helper.forward = event.pressed
	elif event.is_action("player_backwards"):
		_movement_helper.backward = event.pressed
	elif event.is_action("player_left"):
		_movement_helper.left = event.pressed
	elif event.is_action("player_right"):
		_movement_helper.right = event.pressed
	elif event.is_action("player_hold_sprint"):
		_movement_helper.sprinting = not event.pressed
	elif event.is_action("player_fire"):
		if event.pressed:
			_handle_player_fire()
			_restart()

func _restart():
	if player_dead:
		for enemy in get_tree().get_nodes_in_group("enemy"):
			enemy.queue_free()
			
		var Intro = load("res://test_scenes/caleb_intro.tscn")
		TransitionSingleton.transition_to_scene(Intro)

func _input(event):
	
	#Is this a mouse look?
	if event is InputEventMouseMotion:
		
		#We need to adjust the player look based on the event
		_handle_player_look(event)
	
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		if event.button_index == 1 and event.pressed:
			_handle_player_fire()
			_restart()


func _on_HurtBox_body_entered(body):
	
	if body.is_in_group("enemy") and body.is_in_group("bullet"):
		#We got hit!
		body = body as Bullet
		take_damage(body.damage)
		body.queue_free()

