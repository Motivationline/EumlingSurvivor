
shader_type spatial;

render_mode specular_disabled;

uniform vec4 paint_color : source_color = vec4(1.0);
uniform sampler2D paint_texture;
uniform float paint_scale = 1.0;
uniform vec2 paint_offset;
/** Controls how much the paint_texture erodes or roughs up the edges of the object. */
uniform float paint_roughness = 0.1;

uniform sampler2D normal_texture : hint_normal;

const int MAX_VERTICES = 32;
uniform vec2 line[MAX_VERTICES];
uniform int line_size = 0;
uniform float line_width = 0.05;
uniform float fade = 0.05;

varying vec2 local_pos;
varying vec2 world_pos;

void vertex() {
	local_pos = VERTEX.xz;
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
	NORMAL = vec3(0.0, 1.0, 0.0);
	TANGENT = vec3(1.0, 0.0, 0.0);
	BINORMAL = vec3(0.0, 0.0, 1.0);
}

float segment_distance(vec2 p, vec2 a, vec2 b) {
	vec2 ab = b - a;
	float ab_length_squared = dot(ab, ab);

	if (ab_length_squared < 0.000001) {
		return length(p - a);
	}

	float t = clamp(dot(p - a, ab) / ab_length_squared, 0.0, 1.0);
	vec2 closest = a + t * ab;

	return length(p - closest);
}

float unsigned_distance(vec2 p) {
	float d = 1e10;

	for (int i = 0; i < MAX_VERTICES - 1; i++) {
		if (i >= line_size - 1) {
			break;
		}

		d = min(d, segment_distance(p, line[i], line[i + 1]));
	}

	return d;
}

void fragment() {
	vec2 uv = (world_pos + paint_offset) * paint_scale;

	float d = unsigned_distance(local_pos);
	float edge = line_width * 0.5 - texture(paint_texture, uv).r * paint_roughness;
	float mask = 1.0 - smoothstep(edge - fade, edge, d);

	ALBEDO = paint_color.rgb;
	ALPHA = paint_color.a * mask;
	NORMAL_MAP = texture(normal_texture, uv).rgb;
}