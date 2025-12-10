shader_type spatial;
render_mode unshaded;

uniform vec3 flash_color : source_color = vec3(1.0, 0.0, 0.0);
uniform float fresnel_power : hint_range(0.001, 10.0) = 0.5;

instance uniform float flash_amount : hint_range(0,1) = 0.0;

void fragment() {
	ALBEDO = flash_color;
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
	ALPHA = flash_amount * fresnel;
}