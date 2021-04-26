extends Node

var image: ImageTexture = null
var image_data: Image = null

func get_current_screenshot():
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	var viewport = get_viewport()
	
	var screen_image = viewport.get_texture().get_data()
	screen_image.flip_y()
	image = ImageTexture.new()
	image.create_from_image(screen_image)
	image_data = image.get_data()
	image_data.decompress()
	image_data.lock()

func transition_to_scene(scene):
	
	yield(get_current_screenshot(), "completed")
	get_tree().change_scene_to(scene)
	
