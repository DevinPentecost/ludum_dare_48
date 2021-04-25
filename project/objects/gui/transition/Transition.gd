extends TextureRect
tool

signal transition_completed

const ClearColor = Color(0, 0, 0, 0)

export(Texture) var image
export(OpenSimplexNoise) var noise
export(float, 0, 100) var noise_delay_intensity setget _set_noise_delay_intensity
export(int) var noise_offset = 0 setget _set_noise_offset
export(int, 0, 10000) var step setget _set_step

onready var _image_data = image.get_data()

func _set_step(_step):
	step = _step
	update_image()
	
func _set_noise_offset(_noise_offset):
	noise_offset = _noise_offset
	update_image()

func _set_noise_delay_intensity(_noise_delay_intensity):
	noise_delay_intensity = _noise_delay_intensity
	update_image()

# Called when the node enters the scene tree for the first time.
func _ready():
	_image_data.decompress()
	_image_data.lock()
	pass # Replace with function body.

func update_image():
	
	if _image_data == null:
		return
	
	#Make a new image to use
	var new_image = Image.new()
	new_image.create(_image_data.get_width(), _image_data.get_height(), false, Image.FORMAT_RGBA8)
	new_image.lock()
	
	#For each step on the X axis
	var viewport_size = get_viewport_rect().size
	for x_pos in viewport_size.x:
		#Determine the offset
		var noise_sample = (noise.get_noise_2d(x_pos, noise_offset) + 1) / 2
		var delay = noise_delay_intensity * noise_sample
		var push = max(step - delay, 0)
		
		#For every Y step
		for y_pos in viewport_size.y:
			
			#If this pixel has been 'pushed', then draw it as invisible
			if y_pos < push:
				new_image.set_pixel(x_pos, y_pos, ClearColor)
			else:
				#Set it to be previous pixel
				new_image.set_pixel(x_pos, y_pos, _image_data.get_pixel(x_pos, y_pos-push))
	
	new_image.unlock()
	texture.create_from_image(new_image)

func start_transition(time=20):
	$Tween.interpolate_method(self, "_set_step", 0, get_viewport_rect().size.y + 100, time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	emit_signal("transition_completed")

func get_current_screenshot():
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	var viewport = get_viewport()
	
	var screen_image = viewport.get_texture().get_data()
	screen_image.flip_y()
	image = ImageTexture.new()
	image.create_from_image(screen_image)
	_image_data = image.get_data()
	_image_data.decompress()
	_image_data.lock()
