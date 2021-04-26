extends Spatial

onready var _player = get_tree().get_nodes_in_group("player")[0]

func _ready():
	_player.connect("health_changed", self, "_on_Player_health_changed")

func fire():
	$Sprite.play("fire")
	$AudioStreamPlayer.play()

func die():
	$Tween.interpolate_property($DedRed, "opacity", 0, 0.8, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.1)
	$Tween.interpolate_property($Sprite, "translation:y", $Sprite.transform.origin.y, $Sprite.transform.origin.y - 2, 2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	
	#Play die sound
	pass

func _on_Sprite_animation_finished():
	#Go back to normal
	$Sprite.play("default")

func _on_Player_health_changed(new_health):
	$PlayerUI/VBox/HealthBar.value = new_health
	
	#Update the portrait depending on the value
	var portrait_index = 0
	if new_health < 50:
		portrait_index = 1
		$PlayerUI/VBox/Portrait.play("red")
	elif new_health < 80:
		portrait_index = 2
		$PlayerUI/VBox/Portrait.play("yellow")	
	
	
