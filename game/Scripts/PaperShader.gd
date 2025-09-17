extends TileMapLayer

var shader_material: ShaderMaterial

func _ready() -> void:
	Global.PaperTileMap = self
	var shader_code := '''
shader_type canvas_item;
render_mode world_vertex_coords;

// Paper settings
uniform float tile_size = 32.0;
uniform float line_width = 1.0;
uniform vec3 line_color = vec3(0.6);
uniform float noise_strength = 0.05;

// Shadow settings
uniform bool shadow_only = false;
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.2);
uniform float blur_std = 1.0;

varying vec4 pos;
varying mat4 canvasMatrix;
varying vec4 modulate;

void vertex() {
	pos = vec4(VERTEX, 0.0, 0.0);
	canvasMatrix = CANVAS_MATRIX;
	modulate = COLOR;
}

// padded sampling (used for shadow blur)
vec4 padded_sample(sampler2D tex, vec2 uv) {
	vec2 t = abs(uv - vec2(0.5, 0.5));
	float b = (t.x >= 0.5 || t.y >= 0.5) ? 0.0 : 1.0;
	return b * texture(tex, uv);
}

float erf(float x) {
	return 2.0 / sqrt(3.14159265) * sign(x) * sqrt(1.0 - exp(-x*x)) * (sqrt(3.14159265) / 2.0 + 31.0 * exp(-x*x) / 200.0 - 341.0 * exp(-2.0 * x * x) / 8000.0);
}

float gaussian(float x) {
	return 1.0 / sqrt(8.0) / blur_std + erf(x / sqrt(2.0) / blur_std) / sqrt(3.14159265);
}

void fragment() {
	// ==== PAPER EFFECT ====
	float cameraWidth = 1024.0;
	float resizeRatio = SCREEN_PIXEL_SIZE.x * cameraWidth;
	vec4 screenspace = canvasMatrix * pos;
	vec2 globalPos = (resizeRatio * screenspace).xy;

	// grid
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

	// noise
	float n = fract(sin(dot(globalPos.xy, vec2(12.9898,78.233))) * 43758.5453);
	mixed *= (1.0 - n * noise_strength);
	vec4 paper_color = vec4(mixed, base.a);

	// ==== SOFT DROP SHADOW ====
	float weight = 0.0;
	vec2 coord = UV / TEXTURE_PIXEL_SIZE;
	coord -= floor(coord);
	float blur_radius = ceil(blur_std * 3.0);

	for (float x = -float(blur_radius); x <= float(blur_radius); ++x) {
		for (float y = -float(blur_radius); y <= float(blur_radius); ++y) {
			vec2 offset = vec2(x, y) * TEXTURE_PIXEL_SIZE;
			// Sample the texture alpha at the offset position
			float sample_alpha = padded_sample(TEXTURE, UV + offset).a;
			// Only contribute to shadow if the sampled pixel has non-zero alpha
			if (sample_alpha > 0.0) {
				weight += (gaussian(-coord.x + x + 1.0) - gaussian(-coord.x + x))
					* (gaussian(-coord.y + y + 1.0) - gaussian(-coord.y + y))
					* sample_alpha;
			}
		}
	}

	vec4 c = padded_sample(TEXTURE, UV);
	float e = shadow_only ? 0.0 : 1.0;

	// Mix shadow and paper effect, ensuring shadow respects paper's alpha
	vec4 shadow = vec4(shadow_color.rgb, shadow_color.a * weight * c.a);
	vec4 final_color = mix(shadow, paper_color, c.a * e);
	COLOR = final_color * modulate;
}
'''
	var shader = Shader.new()
	shader.code = shader_code

	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter('line_color', Vector3(0.7, 0.6, 0.7))
	shader_material.set_shader_parameter('shadow_color', Color(0,0,0,0.3))
	shader_material.set_shader_parameter('blur_std', 1.0)

	material = shader_material

func _process(_delta: float) -> void:
	var cam_zoom = get_viewport().get_camera_2d().zoom.x
	if shader_material:
		shader_material.set_shader_parameter('tile_size', 12.0 * cam_zoom)
		shader_material.set_shader_parameter('line_width', 0.3 * cam_zoom)
