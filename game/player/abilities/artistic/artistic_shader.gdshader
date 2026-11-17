shader_type spatial;

render_mode specular_disabled;

uniform vec4 paint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D paint_texture;
uniform float paint_scale = 1.0;
uniform vec2 paint_offset;

uniform sampler2D normal_texture : hint_normal;

const int MAX_VERTICES = 32;
uniform vec2 polygon[MAX_VERTICES];
uniform int polygon_size = 0;

uniform float fade = 0.05;

varying vec2 polygon_pos;

void vertex() {
	polygon_pos = VERTEX.xz;
}

float segment_distance(vec2 p, vec2 a, vec2 b) {
	vec2 ab = b - a;
	float t = dot(p - a, ab) / dot(ab, ab);
	t = clamp(t, 0.0, 1.0);
	vec2 closest = a + t * ab;
	return length(p - closest);
}

float unsigned_distance() {
	float d = 1e10;

	for (int i = 0; i < polygon_size; i++) {
		int j = (i + 1) % polygon_size;

		d = min(d, segment_distance(
		    polygon_pos,
		    polygon[i],
		    polygon[j]
		));
	}
	
	return d;
}

void fragment() {
    vec2 uv = (polygon_pos + paint_offset) * paint_scale;

	float d = unsigned_distance();
	float d_random = d + texture(paint_texture, uv).r * -0.3;

	float masked = step(fade, d);
	float masked_smooth = smoothstep(0.0, fade, d_random);

    ALBEDO = paint_color.rgb;
	ALPHA = paint_color.a * masked_smooth;
	NORMAL_MAP = texture(normal_texture, uv).xyz;
}