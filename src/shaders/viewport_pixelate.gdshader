shader_type canvas_item;

// Low-res pixelation shader for SubViewport output
uniform float pixel_size: hint_range(1.0, 8.0) = 2.0;
uniform sampler2D screen_texture: hint_screen_texture, filter_nearest;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 pixel_uv = floor(uv * SCREEN_PIXEL_SIZE * pixel_size) / (SCREEN_PIXEL_SIZE * pixel_size);
    vec4 color = texture(screen_texture, pixel_uv);
    COLOR = color;
}