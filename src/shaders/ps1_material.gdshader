shader_type spatial;
render_mode unshaded, cull_back;

// PS1 Retro Material: Vertex Snapping + Dithering
uniform sampler2D texture_albedo : source_color, filter_nearest, repeat_enable;
uniform vec4 albedo_color : source_color = vec4(0.5, 0.4, 0.3, 1.0);
uniform float vertex_snap : hint_range(0.0, 100.0) = 50.0;

// Bayer 4x4 dithering matrix
const mat4 bayer_matrix = mat4(
	vec4(0.0, 8.0, 2.0, 10.0),
	vec4(12.0, 4.0, 14.0, 6.0),
	vec4(3.0, 11.0, 1.0, 9.0),
	vec4(15.0, 7.0, 13.0, 5.0)
) / 16.0;

void vertex() {
	// PS1 vertex snapping effect
	vec4 snap_pos = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	snap_pos.xyz = snap_pos.xyz / snap_pos.w;
	snap_pos.xy = floor(snap_pos.xy * vertex_snap) / vertex_snap;
	snap_pos.xyz *= snap_pos.w;
	POSITION = snap_pos;
}

void fragment() {
	vec4 tex_color = texture(texture_albedo, UV);
	vec3 color = albedo_color.rgb * tex_color.rgb;

	// Dithering
	ivec2 screen_pos = ivec2(FRAGCOORD.xy) % 4;
	float dither = bayer_matrix[screen_pos.x][screen_pos.y];
	color += (dither - 0.5) * 0.03;

	ALBEDO = color;
	ALPHA = albedo_color.a * tex_color.a;
}
