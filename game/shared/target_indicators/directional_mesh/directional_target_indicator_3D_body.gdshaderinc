#ifdef OCCLUDED
render_mode depth_draw_never, depth_test_inverted;
uniform float alpha_occluded : hint_range(0.0, 1.0) = 0.33;
#endif

uniform sampler2D albedo_texture : hint_default_white, repeat_disable;
uniform sampler2D mask_texture : hint_default_white, repeat_disable;

group_uniforms Base;
instance uniform vec4 color : source_color = vec4(0.0, 1.0, 1.0, 0.8);
instance uniform float extent : hint_range(0.0, 1.0, 0.001) = 0.1;
group_uniforms;

group_uniforms Bounds;
instance uniform float near: hint_range(0.0, 1.0, 0.001) = 0.0;
instance uniform float near_fade: hint_range(0.0, 1.0, 0.001) = 0.1;
instance uniform float far: hint_range(0.0, 1.0, 0.001) = 1.0;
instance uniform float far_fade : hint_range(0.0, 1.0, 0.001) = 0.0;
instance uniform float width: hint_range(0.0, 1.0, 0.001) = 1.0;
instance uniform float width_fade : hint_range(0.0, 1.0, 0.001) = 0.0;
group_uniforms;

group_uniforms Pulse;
instance uniform float pulse : hint_range(0.0, 1.0, 0.001) = 0.0;
instance uniform float pulse_width : hint_range(0.0, 1.0, 0.001) = 0.45;
instance uniform float pulse_far_fade : hint_range(0.0, 1.0, 0.001) = 0.05;
instance uniform float pulse_near_fade : hint_range(0.0, 1.0, 0.001) = 0.3;
instance uniform vec4 pulse_color : source_color = vec4(1.0, 1.0, 0.0, 0.8);
group_uniforms;

varying flat vec2 content_scale;
varying flat vec2 content_offset;

void vertex() {
	ivec2 texture_size = textureSize(albedo_texture, 0);
	float texture_aspect = float(texture_size.x) / float(texture_size.y);
	float node_aspect =  length(MODEL_MATRIX[0].xyz) / length(MODEL_MATRIX[2].xyz);
	float fitted_aspect = texture_aspect / node_aspect;
	content_scale = vec2(1.0);
	if (fitted_aspect < 1.0) {
		content_scale.x = fitted_aspect;
	} else {
		content_scale.y = 1.0 / fitted_aspect;
	}

	content_offset = (vec2(1.0) - content_scale) * 0.5;

	float half_spare_y = 0.5 * max(1.0 - content_scale.y, 0.0);
	content_offset.y -= half_spare_y;
}

void fragment() {
	float pixel_distance_y = UV.y;
	float pixel_distance_center = abs(UV.x - 0.5);
	float inv_near = (1.0 - near);
	float inv_far = (1.0 - far);
	float near_factor = 1.0 - smoothstep(inv_near - near_fade, inv_near, pixel_distance_y);
	float far_factor = smoothstep(inv_far, inv_far + far_fade, pixel_distance_y);
	float side_factor = smoothstep(pixel_distance_center, pixel_distance_center + width_fade * 0.5, width * 0.5);
	
	vec2 arrow_uv = (UV - content_offset) / content_scale;
	vec2 uv = vec2(arrow_uv.x, arrow_uv.y - ((1.0 / content_scale.y) * (1.0 - extent)));
	vec4 texture_color = texture(albedo_texture, uv);
	vec4 body_color = color * texture_color;
	
	float pulse_position = mix(1.0 + pulse_width, 0.0, pulse);
	float pulse_edge_mask = smoothstep(pixel_distance_y, pixel_distance_y + pulse_near_fade, pulse_position) - smoothstep(pixel_distance_y - pulse_far_fade, pixel_distance_y, pulse_position - pulse_width);

	vec4 pulse_texture_mask = texture(mask_texture, uv);
	vec4 pulse_color_ = pulse_color * pulse_texture_mask;
	pulse_color_.a *= pulse_edge_mask;
	
	float alpha_mask = pulse_color_.a * body_color.a;
		
	float pulse_a = max(0.01, pulse_color_.a);
	float body_a = max(0.01, body_color.a);

	float col_a = pulse_color_.a + (1.0 - pulse_color_.a) * body_color.a;
	vec3 col_rgb = (1.0 / col_a) * (pulse_color_.a * pulse_color_.rgb + (1.0 - pulse_color_.a) * body_color.a * body_color.rgb);
	
	ALBEDO = col_rgb;
	ALPHA = col_a;
	
	// bounds
	ALPHA *= near_factor * far_factor * side_factor;
	
	#ifdef OCCLUDED
	ALPHA *= alpha_occluded;
	#endif
}
