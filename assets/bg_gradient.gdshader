shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.035, 0.045, 0.065, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.075, 0.095, 0.130, 1.0);
uniform float horizon : hint_range(0.0, 1.0) = 0.62;

void fragment() {
	float t = smoothstep(0.0, 1.0, UV.y / max(horizon, 0.001));
	vec3 c = mix(top_color.rgb, bottom_color.rgb, t);
	// лёгкая шумовая шероховатость, чтобы не было «пластикового» градиента
	float n = fract(sin(dot(UV * 480.0, vec2(12.9898, 78.233))) * 43758.5453);
	c += (n - 0.5) * 0.006;
	COLOR = vec4(c, 1.0);
}