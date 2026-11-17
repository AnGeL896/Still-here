shader_type canvas_item;

// Непрерывная фактура в мировых координатах.
// Не привязана к тайлам — поэтому сетки не видно.

uniform float noise_scale = 0.32;
uniform float strength : hint_range(0.0, 0.5) = 0.11;
uniform float detail_scale = 2.7;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	vec2 p = VERTEX * noise_scale;
	float n = vnoise(p) * 0.65 + vnoise(p * detail_scale) * 0.35;
	float k = 1.0 + (n - 0.5) * strength * 2.0;
	COLOR.rgb *= k;
}