#ifdef OCCLUDED
render_mode depth_draw_never, depth_test_inverted;
uniform float alpha_occluded : hint_range(0.0, 1.0) = 0.33;
#endif

uniform sampler2D albedo_texture : hint_default_white;
uniform sampler2D mask_texture : hint_default_white;

instance uniform vec4 color : source_color = vec4(0.0, 1.0, 1.0, 0.8);
instance uniform vec4 edge_color : source_color = vec4(1.0, 1.0, 0.0, 0.8);

instance uniform float arc : hint_range(0.0, 1.0) = 0.25;
instance uniform float edge : hint_range(0.0, 1.0) = 0.03;
instance uniform float fade : hint_range(0.0, 1.0) = 0.01;

const vec2 FORWARD = vec2(0.0, -1.0);

void fragment()
{
    vec2 uv = UV;
    vec2 p = uv - vec2(0.5);
    vec4 albedo_tex = texture(albedo_texture, uv);
    vec4 mask_tex = texture(mask_texture, uv);

	vec2 dir = normalize(UV - vec2(0.5));
	
	float angle = acos(dot(dir, FORWARD));
	float arc_half_angle = PI * arc;
	float arc_half_fade = PI * fade;
	float arc_mask = arc < 1.0 || fade > 0.0 ? smoothstep(arc_half_angle, arc_half_angle - arc_half_fade, angle) : 1.0;
	
	float body_half_angle = max(0.0, arc - edge) * PI;
    float body_mask = step(angle, body_half_angle);

    float edge_mask = (1.0 - body_mask);

    vec4 body_col = color * albedo_tex * body_mask;
    vec4 edge_col = edge_color * mask_tex;

    body_col.a *= body_mask;
    edge_col.a *= edge_mask;
	
    if (body_mask > 0.0) {
		ALBEDO = body_col.rgb;
		ALPHA = body_col.a;
	} else {
		ALBEDO = edge_col.rgb;
		ALPHA = edge_col.a;
	}
	ALPHA *= arc_mask;
	
	#ifdef OCCLUDED
	ALPHA *= alpha_occluded;
	#endif
}