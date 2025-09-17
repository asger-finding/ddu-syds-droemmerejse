extends ColorRect

@export var camera_reference: Camera2D
@export var parallax_speed: float = 0.2  # How fast the background moves relative to camera

var shader_material: ShaderMaterial
var original_size

func _ready():
	original_size = size
	if material is ShaderMaterial:
		shader_material = material as ShaderMaterial
	else:
		print("Error: Node needs a ShaderMaterial with the crumpled paper shader")

func _process(_delta):
	if camera_reference and shader_material:
		var camera_pos = camera_reference.global_position
		
		size = original_size / camera_reference.zoom.x
		position = camera_pos - size / 2
		
		shader_material.set_shader_parameter("camera_offset", camera_pos * parallax_speed)
