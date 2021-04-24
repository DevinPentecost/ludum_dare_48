extends KinematicBody


export(float) var health = 100

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _die():
	$AnimatedSprite3D.play("die")
	$Hurtbox.queue_free()
	$CollisionShape.disabled = true
	$AudioStreamPlayer3D.play_die()

func _take_hit(bullet: Bullet):
	bullet.queue_free()
	health -= bullet.damage
	$AudioStreamPlayer3D.play_ow()
	
	if health < 0:
		_die()

func _on_Hurtbox_body_entered(body: PhysicsBody):
	
	#Did we get shot?
	if body is Bullet:
		_take_hit(body)
