extends KinematicBody

const EnemyBulletScene = preload("res://objects/enemy/EnemyBullet.tscn")

export(float) var health = 100
export(float) var hearing_range_squared = 100
export(float) var sight_range_squared = 150

onready var _player: Player = get_tree().get_nodes_in_group("player")[0]
onready var _sleep_timer = $SleepTimer
onready var _sight: RayCast = $Sight
onready var _attack_timer:Timer = $AttackTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	_player.connect("fired", self, "_on_Player_fired")
	
	set_physics_process(true)
	pass # Replace with function body.

enum EnemyState {
	SLEEP,
	CHASE,
	DEAD,
}
var enemy_state = EnemyState.SLEEP


func _physics_process(delta):
	look_at(_player.target.global_transform.origin, Vector3.UP)
	transform.basis.y = Vector3.UP
	
	_look_for_player()
	_try_attack()
	
func _try_attack():
	if enemy_state == EnemyState.CHASE and _attack_timer.time_left == 0:
		_fire()
		_attack_timer.start()
	
func _look_for_player():
	#Look for the player in range
	var distance = global_transform.origin.distance_squared_to(_player.target.global_transform.origin)
	if distance < sight_range_squared:
		#Shoot a ray so we aren't looking through walls
		_sight.cast_to = _sight.to_local(_player.target.global_transform.origin)
		var collider = _sight.get_collider()
		if collider != null:
			if collider == _player.collider or collider == _player:
				_notice_player()

func _die():
	$AnimatedSprite3D.play("die")
	$Hurtbox.queue_free()
	$CollisionShape.disabled = true
	$AudioStreamPlayer3D.play_die()
	enemy_state = EnemyState.DEAD
	set_process(false)
	set_physics_process(false)

func _take_hit(bullet: Bullet):
	bullet.queue_free()
	health -= bullet.damage
	$AudioStreamPlayer3D.play_ow()
	
	if health < 0:
		_die()

func _fire():
	
	$BulletSpawner.look_at(_player.target.global_transform.origin, Vector3.UP)
	
	#Spawn a bullet
	var new_bullet = EnemyBulletScene.instance()
	new_bullet.transform.origin = $BulletSpawner.global_transform.origin
	new_bullet.transform.basis.x = transform.basis.x
	get_tree().root.add_child(new_bullet)
	new_bullet.look_at(_player.target.global_transform.origin, Vector3.UP)

func _on_Hurtbox_body_entered(body: PhysicsBody):
	
	#Did we get shot?
	if body is Bullet:
		_take_hit(body)

func _on_Player_fired():
	
	#Figure out if the player was close enough to hear
	var distance = transform.origin.distance_squared_to(_player.transform.origin)
	if enemy_state == EnemyState.SLEEP:
		enemy_state = EnemyState.CHASE

func _notice_player():
	
	#Start chasing if we're asleep
	if enemy_state == EnemyState.SLEEP:
		enemy_state = EnemyState.CHASE
	
	_sleep_timer.start()

func _on_SleepTimer_timeout():
	
	#We haven't noticed the player in a while... time to go back to sleep
	enemy_state = EnemyState.SLEEP
	print("I lost the player...")
