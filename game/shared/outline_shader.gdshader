shader_type spatial;
render_mode cull_front, unshaded;

uniform vec4 color : source_color;
uniform float width = 0.05;

void vertex() {
	vec3 smooth_normal = NORMAL;
	if (dot(CUSTOM0.xyz, CUSTOM0.xyz) > 0.0)
		smooth_normal = CUSTOM0.xyz * 2.0 - 1.0;
	//vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	//vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * smooth_normal);
	//
	//vec2 offset = normalize(clip_normal.xy) / VIEWPORT_SIZE * clip_position.w * width * 2.0;
	//
	//clip_position.xy += offset;
	//
	//POSITION = clip_position;
	VERTEX += width * smooth_normal;
}

void fragment() {
	ALBEDO = color.rgb;
	ALPHA = color.a;
}