extends Spatial


var num_enemies = 0
var lowering_walls = false
var raising_stairs = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$Stairs.transform.origin.y = -30


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if lowering_walls:
		$barrier1.transform.origin -= Vector3(0, delta, 0)
		$barrier2.transform.origin -= Vector3(0, delta, 0)
		$barrier3.transform.origin -= Vector3(0, delta, 0)
		$barrier4.transform.origin -= Vector3(0, delta, 0)
		$barrier5.transform.origin -= Vector3(0, delta, 0)
		$barrier6.transform.origin -= Vector3(0, delta, 0)
		$barrier7.transform.origin -= Vector3(0, delta, 0)
		$barrier8.transform.origin -= Vector3(0, delta, 0)
		$barrier9.transform.origin -= Vector3(0, delta, 0)
		$barrier10.transform.origin -= Vector3(0, delta, 0)
		$barrier11.transform.origin -= Vector3(0, delta, 0)
		$barrier12.transform.origin -= Vector3(0, delta, 0)
	
	if raising_stairs:
		$Stairs.rotate_y(delta * 0.66)
		if $Stairs.transform.origin.y < 0:
			$Stairs.transform.origin.y += delta

func _on_Enemy_ready():
	num_enemies += 1

func _on_Enemy_died():
	num_enemies -= 1
	
	# Enough dead?
	if num_enemies <= 0:
		lowering_walls = true
		$Timer.start()

func _on_Timer_timeout():
	raising_stairs = true
	lowering_walls = false
	$Stairs/Spawner.start_timer()
