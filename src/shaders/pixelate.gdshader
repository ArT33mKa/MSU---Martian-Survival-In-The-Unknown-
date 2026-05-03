shader_type canvas_item;

// PS1-Style Pixelation Shader (lighter version)
uniform float resolution_scale : hint_range(1.0, 8.0) = 2.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 pixel_size = screen_size / resolution_scale;

	// Snap to pixel grid
	vec2 pixelated_uv = floor(uv * pixel_size) / pixel_size;

	vec4 color = texture(TEXTURE, pixelated_uv);

	// Safety check to prevent black/blue artifacts
	if (color.a < 0.01) {
		color = vec4(0.8, 0.5, 0.3, 1.0); // Fallback to mars color
	}

	COLOR = color;
}
