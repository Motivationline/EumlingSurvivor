#ifdef OCCLUDED
render_mode depth_draw_never, depth_test_inverted;
uniform float alpha_occluded : hint_range(0.0, 1.0) = 0.33;
#endif

instance uniform vec4 color : source_color = vec4(0.0, 1.0, 1.0, 0.8);
instance uniform vec4 edge_color : source_color = vec4(1.0, 1.0, 0.0, 0.8);

instance uniform float radius : hint_range(0.0, 1.0, 0.001) = 1.0;
instance uniform float width: hint_range(0.0, 1.0, 0.001) = 0.75;

instance uniform float edge : hint_range(0.0, 1.0) = 0.2;
instance uniform float edge_fade: hint_range(0.0, 1.0, 0.001) = 0.05;

instance uniform float inner_fade: hint_range(0.0, 1.0, 0.001) = 0.05;
instance uniform float outer_fade : hint_range(0.0, 1.0, 0.001) = 0.05;

instance uniform float arc: hint_range(0.0, 1.0, 0.001) = 0.5;
instance uniform float arc_fade: hint_range(0.0, 1.0, 0.001) = 0.05;

const vec2 FORWARD = vec2(0.0, -1.0);

void fragment() {
	float r = radius * 0.5;
	float w = width * 0.5;
	float dist = distance(UV, vec2(0.5));
	
	float ring_mask = smoothstep(dist, dist + outer_fade, r) - smoothstep(dist - inner_fade, dist, r - w);

	vec2 dir = normalize(UV - vec2(0.5));
	float angle = acos(dot(dir, FORWARD));
	
	float arc_half_angle = PI * arc;
	float arc_half_fade = PI * arc_fade;
	float arc_mask = arc < 1.0 || arc_fade > 0.0 ? smoothstep(arc_half_angle, arc_half_angle - arc_half_fade, angle) : 1.0;

	float body_half_angle = PI * max(0.0, arc - edge);
    float body_mask = edge > 0.0 ? smoothstep(angle - edge_fade * PI, angle, body_half_angle) : 1.0;
	
	//float edge_mask = (1.0 - body_mask);

	// Porter/Duff compositing
	//vec4 body_col = color;
    //vec4 edge_col = edge_color;
    //body_col.a *= body_mask;
    //edge_col.a *= edge_mask;
	//ALPHA = edge_col.a + (1.0 - edge_col.a) * body_col.a;
	//ALBEDO = (1.0 / ALPHA) * (edge_col.a * edge_col.rgb + (1.0 - edge_col.a) * body_col.a * body_col.rgb);
	
	ALBEDO = mix(edge_color.rgb, color.rgb, body_mask);
	ALPHA = mix(edge_color.a ,color.a, body_mask);
	
	ALPHA *= ring_mask * arc_mask;
	
	#ifdef OCCLUDED
	ALPHA *= alpha_occluded;
	#endif
}