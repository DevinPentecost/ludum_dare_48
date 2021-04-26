extends Area
signal level_ended

onready var _player: Player = get_tree().get_nodes_in_group("player")[0]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_LevelEnd_body_entered(body):
	if body == _player:
		#Level is over!
		print('Level has ended!')
		$CollisionShape.disabled = true
		emit_signal("level_ended")
		
		for enemy in get_tree().get_nodes_in_group("enemy"):
			enemy.queue_free()
