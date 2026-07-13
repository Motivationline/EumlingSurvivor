shader_type spatial;

uniform sampler2D albedo_texture : source_color;

#include "wind_global_uniforms.gdshaderinc"

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 wind_direction_normalized = normalize(wind_direction);
	vec2 wind_noise_uv = (world_position.xz - TIME * wind_speed * wind_direction_normalized.xz) * wind_frequency;
	float noise = texture(wind_noise, wind_noise_uv).r;
	
	ALBEDO = vec3(noise);
}
