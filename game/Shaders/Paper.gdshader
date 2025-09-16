shader_type canvas_item;
render_mode world_vertex_coords;

uniform float tile_size = 32.0;       // size of one tile in pixels
uniform float line_width = 1.0;       // line thickness in pixels
uniform vec3 line_color = vec3(0.6);  // dark-grey line color
uniform float noise_strength = 0.05;  // how strong the noise darkening is

// Varyings to get world position
varying vec4 pos;
varying mat4 canvasMatrix;

void vertex() {
    // Pass the local vertex position and canvas matrix to fragment
    pos = vec4(VERTEX, 0.0, 0.0);
    canvasMatrix = CANVAS_MATRIX;
}

void fragment() {
    // Convert to global (editor) coordinates [20†L90-L99]
    float cameraWidth = 1024.0; // e.g. your game width in pixels
    float resizeRatio = SCREEN_PIXEL_SIZE.x * cameraWidth;
    vec4 screenspace = canvasMatrix * pos;
    vec2 globalPos = (resizeRatio * screenspace).xy;

    // Calculate distance to nearest tile line along X and Y
    float fx = fract(globalPos.x / tile_size);
    float fy = fract(globalPos.y / tile_size);
    float distX = min(fx, 1.0 - fx);
    float distY = min(fy, 1.0 - fy);

    // Antialiased line alpha (approx 1 inside line_width)
    float pixel_w = line_width / tile_size;
    float anti = fwidth(globalPos.x / tile_size);
    float lineX = 1.0 - smoothstep(pixel_w - anti, pixel_w + anti, distX);
    anti = fwidth(globalPos.y / tile_size);
    float lineY = 1.0 - smoothstep(pixel_w - anti, pixel_w + anti, distY);

    // Combined line influence (if either X or Y line)
    float lineAlpha = clamp(lineX + lineY, 0.0, 1.0);

    // Sample the base texture (white paper)
    vec4 base = texture(TEXTURE, UV);

    // Mix base color with lines
    vec3 mixed = mix(base.rgb, line_color, lineAlpha);

    // Darken by white noise to give a grain apperance
    float n = fract(sin(dot(globalPos.xy, vec2(12.9898,78.233))) * 43758.5453);
    mixed *= (1.0 - n * noise_strength);

    COLOR = vec4(mixed, base.a);
}
