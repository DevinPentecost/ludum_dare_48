extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

const level_2 = preload("res://scenes/level_2.tscn")

func _on_LevelEnd_level_ended():
	yield(TransitionSingleton.get_current_screenshot(), "completed")
	get_tree().change_scene_to(level_2)
