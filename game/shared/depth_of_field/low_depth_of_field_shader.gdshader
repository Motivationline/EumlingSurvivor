shader_type spatial;
render_mode unshaded;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

uniform float far_distance = 10.0;
uniform float far_transition = 5.0;

uniform float near_distance = 2.0;
uniform float near_transition = 1.0;

uniform float amount : hint_range(0.0, 5.0) = 2.5;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
	float z = abs(upos.z / upos.w);

	float blur = 0.0;
	if (z > far_distance)
	 	blur = smoothstep(far_distance, far_distance + far_transition, z);
	else if (z < near_distance)
	 	blur = smoothstep(near_distance, near_distance - near_transition, z);

	blur *= amount;
	
	vec4 color = textureLod(screen_texture, SCREEN_UV, blur);
	ALBEDO = color.xyz;
	ALPHA = 1.0;
}