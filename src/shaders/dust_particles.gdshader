shader_type particles;

// Martian Dust Particles
uniform float dust_spread : hint_range(1.0, 50.0) = 25.0;
uniform float dust_height : hint_range(0.0, 20.0) = 5.0;

void start() {
	// Random position in area
	float angle = RANDOM_SEED * TAU;
	float radius = sqrt(RANDOM_SEED) * dust_spread;

	TRANSFORM[3][0] = cos(angle) * radius;
	TRANSFORM[3][1] = (RANDOM_SEED - 0.5) * dust_height;
	TRANSFORM[3][2] = sin(angle) * radius;

	// Random velocity (slow drift)
	VELOCITY = vec3(
		(RANDOM_SEED - 0.5) * 0.5,
		(RANDOM_SEED - 0.3) * 0.2,
		(RANDOM_SEED - 0.5) * 0.5
	);
}

void process() {
	// Slow drift movement
	TRANSFORM[3].xyz += VELOCITY * DELTA;

	// Fade in/out based on lifetime
	float life = 1.0 - (float(FRAME) / float(LIFETIME));
	COLOR.a = smoothstep(0.0, 0.2, life) * smoothstep(1.0, 0.8, life) * 0.3;

	// Recycle particles
	if (TRANSFORM[3].y < -2.0 || TRANSFORM[3].y > dust_height + 2.0) {
		TRANSFORM[3].y = dust_height;
	}
}
