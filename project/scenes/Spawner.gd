extends Spatial

const enemyscene = preload("res://objects/enemy/Enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start_timer():
	$Timer.start()

func _spawn():
	print("spawning a man")
	var new_enemy = enemyscene.instance()
	new_enemy.transform = transform
	get_tree().root.add_child(new_enemy)
	

func _on_Timer_timeout():
	
	_spawn()
