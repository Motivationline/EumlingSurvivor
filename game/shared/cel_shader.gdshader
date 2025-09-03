shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D albedo_texture : source_color, filter_linear, repeat_disable;

uniform sampler2D diffuse_ramp : filter_nearest, repeat_disable;
uniform sampler2D specular_ramp : filter_nearest, repeat_disable;
uniform sampler2D rim_ramp : filter_nearest, repeat_disable;

uniform float shininess = 128.0;

uniform bool use_HDR = true;
uniform bool use_diffuse_smooth_attenuation = true;
uniform bool use_specular_smooth_attenuation = true;

float ramp(sampler2D ramp, float x) {
	return texture(ramp, vec2(x, 0)).r;
}

void fragment() {
    vec4 color = texture(albedo_texture, UV) * albedo_color;
    ALBEDO = color.rgb;
}

void light() {
	vec3 light_color = LIGHT_COLOR / PI;

	// diffuse
	float diffuse_factor = max(dot(NORMAL, LIGHT), 0.0) * ATTENUATION;
	diffuse_factor = ramp(diffuse_ramp, diffuse_factor);
	vec3 diffuse = min(light_color * diffuse_factor, 1.0);

	// rim
	float rim_factor = pow(1.0 - dot(NORMAL, VIEW), 1.0);
	rim_factor = ramp(rim_ramp, rim_factor);
	vec3 rim = light_color * rim_factor * diffuse_factor;

	diffuse = diffuse + rim;
	if (use_diffuse_smooth_attenuation)
		diffuse = diffuse * ATTENUATION;

	if (!use_HDR)
		diffuse = min(diffuse, 1.0);

	DIFFUSE_LIGHT += diffuse;

	// specular
	float specular_factor = pow(max(dot(NORMAL, normalize(LIGHT + VIEW)), 0.0), shininess) * ATTENUATION;
	specular_factor = ramp(specular_ramp, specular_factor);
    vec3 specular = light_color * specular_factor;

	if (use_specular_smooth_attenuation)
		specular = specular * ATTENUATION;

	if (!use_HDR)
		specular = min(specular, 1.0);

	SPECULAR_LIGHT += specular;
}
