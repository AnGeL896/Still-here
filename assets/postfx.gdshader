shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.5;
uniform float grain_amount : hint_range(0.0, 0.3) = 0.022;
uniform float grain_scale : hint_range(0.5, 4.0) = 1.0;
uniform float desaturation : hint_range(0.0, 1.0) = 0.16;
uniform float contrast : hint_range(0.5, 2.0) = 1.04;
uniform vec4 tint : source_color = vec4(0.86, 0.93, 1.0, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 col = texture(screen_texture, uv).rgb;

	// Р»С‘РіРєРѕРµ РѕР±РµСЃС†РІРµС‡РёРІР°РЅРёРµ РІ С…РѕР»РѕРґРЅС‹Р№ С‚РѕРЅ
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(col, vec3(luma) * tint.rgb, desaturation);

	// РєРѕРЅС‚СЂР°СЃС‚
	col = (col - 0.5) * contrast + 0.5;

	// РІРёРЅСЊРµС‚РєР°
	vec2 d = uv - 0.5;
	float v = 1.0 - dot(d, d) * vignette_strength * 1.9;
	col *= clamp(v, 0.0, 1.0);

	// Р·РµСЂРЅРѕ: РїСЂРёРІСЏР·Р°РЅРѕ Рє В«РїРёРєСЃРµР»СЊРЅРѕР№В» СЃРµС‚РєРµ, Р° РЅРµ Рє СЌРєСЂР°РЅСѓ
	vec2 px = floor(uv * vec2(480.0, 270.0));
	float g = hash(px + floor(TIME * 24.0));
	col += (g - 0.5) * grain_amount;

	COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
}