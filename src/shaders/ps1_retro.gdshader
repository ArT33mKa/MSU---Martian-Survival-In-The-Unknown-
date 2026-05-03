shader_type spatial;
render_mode unshaded, cull_back;

// PS1-Style Retro Shader: Vertex Snapping + Affine Texture Mapping + Dithering
uniform float vertex_snap_intensity: hint_range(0.0, 1.0) = 0.5;
uniform sampler2D texture_albedo: source_color, filter_nearest;
uniform vec3 fog_color: source_color = vec3(0.8, 0.5, 0.3);
uniform float fog_density: hint_range(0.0, 1.0) = 0.3;

// Dithering pattern (Bayer 4x4)
const mat4 dither_matrix = mat4(
    vec4(0.0, 8.0, 2.0, 10.0),
    vec4(12.0, 4.0, 14.0, 6.0),
    vec4(3.0, 11.0, 1.0, 9.0),
    vec4(15.0, 7.0, 13.0, 5.0)
) / 16.0;

varying vec3 world_pos;
varying float vertex_distance;

void vertex() {
    // Vertex snapping (PS1 effect)
    float snap_grid = 100.0 * vertex_snap_intensity;
    vec4 snapped_vertex = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
    snapped_vertex.xyz = snapped_vertex.xyz / snapped_vertex.w;
    snapped_vertex.xy = floor(snapped_vertex.xy * snap_grid) / snap_grid;
    snapped_vertex.xyz *= snapped_vertex.w;
    POSITION = snapped_vertex;

    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vertex_distance = length(VERTEX);
}

void fragment() {
    // Affine texture mapping (no perspective correction)
    vec2 uv = UV;
    vec4 albedo_tex = texture(texture_albedo, uv);

    // Dithering
    ivec2 screen_pos = ivec2(FRAGCOORD.xy) % 4;
    float dither_value = dither_matrix[screen_pos.x][screen_pos.y];

    // Fog calculation
    float fog_factor = clamp(vertex_distance * fog_density * 0.01, 0.0, 1.0);
    vec3 final_color = mix(albedo_tex.rgb, fog_color, fog_factor);

    // Apply dithering to color
    final_color += (dither_value - 0.5) * 0.05;

    ALBEDO = final_color;
    ALPHA = albedo_tex.a;
}