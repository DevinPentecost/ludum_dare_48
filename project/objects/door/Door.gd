extends KinematicBody

export(float) var activate_time = 10

var can_activate = false
var busy = false

onready var original_position = global_transform.origin
onready var end_position = $Target.global_transform.origin
onready var start = original_position
onready var target = end_position

onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_unhandled_key_input(true)

func activate():
	tween.interpolate_property(self, "translation", start, target, activate_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	busy = true
	yield(tween, "tween_all_completed")
	var _start = start
	start = target
	target = _start
	busy = false

func _on_Activatee_area_entered(area):
	if area.is_in_group("activator"):
		can_activate = true


func _on_Activatee_area_exited(area):
	if area.is_in_group("activator"):
		can_activate = true

func _unhandled_key_input(event):
	if event.is_action_pressed("player_activate"):
		if can_activate and not busy:
			activate()
