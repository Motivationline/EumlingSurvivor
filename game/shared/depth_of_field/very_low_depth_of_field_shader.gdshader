shader_type spatial;
render_mode unshaded;

uniform float amount : hint_range(0.0, 5.0) = 2.5;
uniform float dist : hint_range(0.0, 0.5) = 0.33;
uniform float transition : hint_range(0.0, 0.5) = 0.1;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	float distance_from_center = abs(SCREEN_UV.y - 0.5);
	float mask = smoothstep(dist, dist + transition, distance_from_center);
	float blur = amount * mask;
    
    ALBEDO = textureLod(screen_texture, SCREEN_UV, blur).xyz;
	ALPHA = 1.0;
}
