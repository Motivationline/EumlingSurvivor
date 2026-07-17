shader_type spatial;
stencil_mode read, write, compare_not_equal, 1;
render_mode unshaded, depth_draw_always;

uniform vec4 outline_color : source_color;

/** Outline width in percent of viewport height. */
uniform float outline_width: hint_range(0.0, 5, 0.01) = 1.0;

void vertex() {
	vec3 smooth_normal = NORMAL;
	if (dot(CUSTOM0.xyz, CUSTOM0.xyz) > 0.0)
		smooth_normal = CUSTOM0.xyz * 2.0 - 1.0;
		
	vec4 clip_position = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec3 clip_normal = mat3(PROJECTION_MATRIX) * MODELVIEW_NORMAL_MATRIX * smooth_normal;

	vec2 screen_normal = normalize(clip_normal.xy * VIEWPORT_SIZE) / VIEWPORT_SIZE;
	float screen_outline_width = outline_width * 0.01 * VIEWPORT_SIZE.y;
	vec2 offset = screen_normal * screen_outline_width * clip_position.w * 2.0;

	clip_position.xy += offset;
	POSITION = clip_position;
}

void fragment() {
	ALBEDO = outline_color.rgb;
	ALPHA = 1.0;
}