extends Spatial

onready var _player = get_tree().get_nodes_in_group("player")[0]
var dead = false

func _ready():
	_player.connect("health_changed", self, "_on_Player_health_changed")

func fire():
	$Sprite.play("fire")
	$AudioStreamPlayer.play()

func hurt():
	$Tween.interpolate_property($DedRed, "opacity", 0, 0.8, 0.2, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	if dead:
		return
	$Tween.interpolate_property($DedRed, "opacity", 0.8, 0, 0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)

func die():
	dead = true
	$Tween.interpolate_property($DedRed, "opacity", 0, 0.8, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.1)
	$Tween.interpolate_property($Sprite, "translation:y", $Sprite.transform.origin.y, $Sprite.transform.origin.y - 2, 2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()


func _on_Sprite_animation_finished():
	#Go back to normal
	$Sprite.play("default")

func _on_Player_health_changed(new_health):
	$PlayerUI/HealthBar.value = new_health
	
	#Update the portrait depending on the value
	var portrait_index = 0
	if new_health < 65:
		portrait_index = 1
	elif new_health < 35:
		portrait_index = 2
	
	
