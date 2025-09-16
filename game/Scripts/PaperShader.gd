extends TileMapLayer

var shader_material: ShaderMaterial

func _ready() -> void:
	var shader_code := """
shader_type canvas_item;
render_mode world_vertex_coords;

uniform float tile_size = 32.0;
uniform float line_width = 1.0;
uniform vec3 line_color = vec3(0.6);
uniform float noise_strength = 0.05;

varying vec4 pos;
varying mat4 canvasMatrix;

void vertex() {
	pos = vec4(VERTEX, 0.0, 0.0);
	canvasMatrix = CANVAS_MATRIX;
}

void fragment() {
	float cameraWidth = 1024.0;
	float resizeRatio = SCREEN_PIXEL_SIZE.x * cameraWidth;
	vec4 screenspace = canvasMatrix * pos;
	vec2 globalPos = (resizeRatio * screenspace).xy;

	float fx = fract(globalPos.x / tile_size);
	float fy = fract(globalPos.y / tile_size);
	float distX = min(fx, 1.0 - fx);
	float distY = min(fy, 1.0 - fy);

	float pixel_w = line_width / tile_size;
	float anti = fwidth(globalPos.x / tile_size);
	float lineX = 1.0 - smoothstep(pixel_w - anti, pixel_w + anti, distX);
	anti = fwidth(globalPos.y / tile_size);
	float lineY = 1.0 - smoothstep(pixel_w - anti, pixel_w + anti, distY);
	float lineAlpha = clamp(lineX + lineY, 0.0, 1.0);

	vec4 base = texture(TEXTURE, UV);
	vec3 mixed = mix(base.rgb, line_color, lineAlpha);

	float n = fract(sin(dot(globalPos.xy, vec2(12.9898,78.233))) * 43758.5453);
	mixed *= (1.0 - n * noise_strength);

	COLOR = vec4(mixed, base.a);
}
"""
	var shader = Shader.new()
	shader.code = shader_code

	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter("line_color", Vector3(0.7, 0.6, 0.7))

	material = shader_material

func _process(_delta: float) -> void:
	var cam_zoom = get_viewport().get_camera_2d().zoom.x
	if shader_material:
		shader_material.set_shader_parameter("tile_size", 12.0 * cam_zoom)
		shader_material.set_shader_parameter("line_width", 0.3 * cam_zoom)
