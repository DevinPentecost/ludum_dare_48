extends RigidBody
class_name Bullet

export(float) var damage = 30
export(float) var speed = 30


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var target = null
func shoot_at(the_target):
	target = the_target
	
	look_at(target.global_transform.origin, Vector3.UP)
	apply_impulse(Vector3.ZERO, transform.basis.z.normalized() * speed * -1)

func _on_LifetimeTimer_timeout():
	queue_free()
