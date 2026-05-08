shader_type canvas_item;
render_mode blend_premul_alpha;

group_uniforms Base;
instance uniform vec4 color : source_color = vec4(0.0, 0.7, 0.8, 0.9);
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
instance uniform vec4 pulse_color : source_color = vec4(1.0, 1.0, 0.5, 0.75);
group_uniforms;

group_uniforms Internal;
instance uniform vec2 decal_size = vec2(1.0, 1.0);
group_uniforms;

varying flat vec2 content_scale;
varying flat vec2 content_offset;

void vertex() {
	float texture_aspect = TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x;
	float decal_aspect = decal_size.x / decal_size.y;
	float fitted_aspect = texture_aspect / decal_aspect;
	content_scale = vec2(1.0);
	if (fitted_aspect < 1.0) {
		content_scale.x = fitted_aspect;
	} else {
		content_scale.y = 1.0 / fitted_aspect;
	}

	content_offset = (vec2(1.0) - content_scale) * 0.5;

	// Elon
	float half_spare_y = 0.5 * max(1.0 - content_scale.y, 0.0);
	content_offset.y -= half_spare_y;
}

void fragment() {
	float pixel_distance_y = UV.y;
	float pixel_distance_center = abs(UV.x - 0.5);
	float half_near = (1.0 - near);
	float half_far = (1.0 - far);
	float far_factor = smoothstep(half_far, half_far + far_fade, pixel_distance_y);
	float near_factor = 1.0 - smoothstep(half_near - near_fade, half_near, pixel_distance_y);
	float side_factor = smoothstep(pixel_distance_center, pixel_distance_center + width_fade * 0.5, width * 0.5);
	
	vec2 arrow_uv = (UV - content_offset) / content_scale;
	vec2 uv = vec2(arrow_uv.x, arrow_uv.y - ((1.0 / content_scale.y) * (1.0 - extent)));
	vec4 texture_color = texture(TEXTURE, uv);
	
	float pulse_position = mix(1.0 + pulse_width, 0.0, pulse);
	float pulse_factor = smoothstep(pixel_distance_y, pixel_distance_y + pulse_near_fade, pulse_position) - smoothstep(pixel_distance_y - pulse_far_fade, pixel_distance_y, pulse_position - pulse_width);

	float pulse_mask = texture_color.a > 0.0 ? 1.0 : 0.0;
	vec4 pulse_color_ = pulse_color * pulse_mask;
	pulse_color_.a *= pulse_factor;
	
	COLOR = color * texture_color;
	COLOR = mix(COLOR, pulse_color_, pulse_color_.a);
	COLOR.a *= near_factor * far_factor * side_factor;
}
