extends RigidBody
class_name Bullet

export(float) var damage = 30
export(float) var speed = 30


# Called when the node enters the scene tree for the first time.
func _ready():
	apply_impulse(Vector3.ZERO, transform.basis.x.normalized()*speed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_LifetimeTimer_timeout():
	queue_free()
