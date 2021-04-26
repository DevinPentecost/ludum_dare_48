extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var noise = OpenSimplexNoise.new()
var dogshaketime = 0

onready var start_pos = self.transform.origin

# Called when the node enters the scene tree for the first time.
func _ready():
	# Configure
	self.noise.seed = randi()
	self.noise.octaves = 4
	self.noise.period = 20.0
	self.noise.persistence = 0.8
	

func _process(delta):	
	dogshaketime += delta
	var slow_y = noise.get_noise_2d(dogshaketime * 0.5, 1.0) * 0.5
	var fast_y = noise.get_noise_2d(dogshaketime * 10, 1.0) * 0.10
	self.transform.origin = start_pos + Vector3(0, slow_y + fast_y, 0)
	
	$Leg1.rotate_x(delta * 10)
	$Leg2.rotate_x(delta * 12)

