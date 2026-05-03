shader_type spatial;

// Mars Ground with Normal Mapping and Craters
uniform vec4 base_color : source_color = vec4(0.6, 0.35, 0.2, 1.0);
uniform vec4 dark_color : source_color = vec4(0.4, 0.25, 0.15, 1.0);
uniform vec4 crater_color : source_color = vec4(0.3, 0.2, 0.12, 1.0);
uniform float noise_scale : hint_range(0.1, 10.0) = 3.0;
uniform float crater_scale : hint_range(0.1, 5.0) = 1.5;
uniform float normal_strength : hint_range(0.0, 2.0) = 0.8;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.9;

// Hash function for noise
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Smooth noise
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);

	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Crater function (circular depressions)
float crater(vec2 uv, vec2 center, float radius) {
	float dist = length(uv - center);
	if (dist < radius) {
		float depth = 1.0 - (dist / radius);
		return depth * depth; // Smooth crater shape
	}
	return 0.0;
}

void fragment() {
	vec2 uv = UV * noise_scale;

	// Multi-octave noise for terrain variation
	float n = 0.0;
	n += noise(uv * 4.0) * 0.5;
	n += noise(uv * 8.0) * 0.25;
	n += noise(uv * 16.0) * 0.125;
	n += noise(uv * 32.0) * 0.0625;

	// Create craters
	vec2 crater_uv = UV * crater_scale;
	float craters = 0.0;
	craters += crater(crater_uv, vec2(0.3, 0.4), 0.15);
	craters += crater(crater_uv, vec2(0.7, 0.2), 0.12);
	craters += crater(crater_uv, vec2(0.5, 0.8), 0.18);
	craters += crater(crater_uv, vec2(0.15, 0.65), 0.1);
	craters += crater(crater_uv, vec2(0.85, 0.75), 0.13);
	craters += crater(crater_uv, vec2(0.4, 0.1), 0.08);

	// Mix colors based on noise and craters
	vec3 color = mix(dark_color.rgb, base_color.rgb, n);
	color = mix(color, crater_color.rgb, craters * 0.7);

	// Add small rocks with softer mask to avoid harsh artifact-like patches.
	float rocks_noise = noise(uv * 12.0);
	float rocks = smoothstep(0.78, 0.92, rocks_noise);
	color = mix(color, dark_color.rgb * 0.55, rocks * 0.22);

	// Calculate normal map for depth
	float height = n - craters * 0.3;
	vec3 normal = normalize(vec3(
		dFdx(height) * normal_strength,
		dFdy(height) * normal_strength,
		1.0
	));

	ALBEDO = color;
	NORMAL = normal;
	ROUGHNESS = roughness_value;
	SPECULAR = 0.1;
}
