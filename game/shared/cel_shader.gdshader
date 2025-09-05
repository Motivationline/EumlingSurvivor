shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D albedo_texture : source_color, filter_linear, repeat_disable;

uniform sampler2D diffuse_ramp : filter_nearest, repeat_disable, hint_default_black;

uniform sampler2D specular_ramp : filter_nearest, repeat_disable, hint_default_black;
uniform float specular_focus : hint_range(0.0, 1.0) = 0.5;

uniform sampler2D rim_ramp : filter_nearest, repeat_disable, hint_default_black;
//uniform float rim_focus_pow : hint_range(0.0, 1.0) = 0.0;
uniform float rim_focus : hint_range(0.0, 1.0) = 0.5;

uniform bool use_HDR = true;
uniform bool use_diffuse_smooth_attenuation = true;
uniform bool use_specular_smooth_attenuation = true;

vec3 ramp(sampler2D ramp, float x) {
    return texture(ramp, vec2(x, 0)).rgb;
}

void fragment() {
    vec4 color = texture(albedo_texture, UV) * albedo_color;
    ALBEDO = color.rgb;
}

void light() {
	vec3 light_color = LIGHT_COLOR / PI;
	float attenuation_clamped = min(ATTENUATION, 1.0);
	float n_dot_l = dot(NORMAL, LIGHT);
	float n_dot_l_clamped = max(dot(NORMAL, LIGHT), 0.0);
	
	// diffuse
	float diffuse_factor = n_dot_l_clamped * attenuation_clamped;

	vec3 diffuse_ramp_color = ramp(diffuse_ramp, diffuse_factor);
	vec3 diffuse_color = min(light_color * diffuse_ramp_color, 1.0);

	// rim
	float rim_fresnel = 1.0 - dot(NORMAL, VIEW);
	float rim_coverage = n_dot_l * 0.5 + 0.5; // remap from [-1, 1] to [0, 1]
	//float rim_mask_pow = pow(rim_coverage, exp2(rim_focus_pow / 0.05));
	float rim_mask = smoothstep(rim_focus, 1.0, rim_coverage);
	float rim_factor = rim_fresnel * rim_mask * attenuation_clamped;

	vec3 rim_ramp_color = ramp(rim_ramp, rim_factor);
	vec3 rim_color = light_color * rim_ramp_color;

	diffuse_color = diffuse_color + rim_color;
	if (use_diffuse_smooth_attenuation)
		diffuse_color = diffuse_color * ATTENUATION;

	if (!use_HDR)
		diffuse_color = min(diffuse_color, 1.0);

	DIFFUSE_LIGHT += diffuse_color;

	if(n_dot_l_clamped > 0.0) {
		// specular
		float specular_factor = max(dot(NORMAL, normalize(LIGHT + VIEW)), 0.0);
		specular_factor = pow(specular_factor, exp2(specular_focus / 0.05)) * attenuation_clamped;

		vec3 specular_ramp_color = ramp(specular_ramp, specular_factor);
	    vec3 specular_color = light_color * specular_ramp_color;

		if (use_specular_smooth_attenuation)
			specular_color = specular_color * ATTENUATION;

		if (!use_HDR)
			specular_color = min(specular_color, 1.0);

		SPECULAR_LIGHT += specular_color;
	}
}
