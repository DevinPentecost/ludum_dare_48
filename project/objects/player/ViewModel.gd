extends Spatial

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
