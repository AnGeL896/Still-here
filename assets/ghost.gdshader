shader_type canvas_item;

uniform vec4 tint : source_color = vec4(0.78, 0.90, 1.0, 1.0);
uniform float alpha : hint_range(0.0, 1.0) = 0.95;
uniform float dissolve : hint_range(0.0, 1.0) = 0.0;
uniform float noise_scale = 0.16;
uniform float softness : hint_range(0.01, 0.5) = 0.09;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
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

float fbm(vec2 p) {
	float v = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 3; i++) {
		v += vnoise(p) * amp;
		p *= 2.03;
		amp *= 0.5;
	}
	return v;
}

void fragment() {
	// локальная позиция: у каждой части тела свой шум, выглядит органично
	vec2 p = VERTEX * noise_scale;
	float n = fbm(p);
	float mask = smoothstep(dissolve - softness, dissolve + softness, n);
	COLOR = vec4(tint.rgb, mask * alpha);
}