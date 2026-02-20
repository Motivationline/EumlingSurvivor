shader_type spatial;

uniform sampler2D albedo_texture : source_color;

global uniform sampler2D wind_noise;
global uniform float wind_noise_scale;
global uniform float wind_speed;
global uniform float wind_strength;
global uniform vec3 wind_direction;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 wind_noise_uv = (world_position.xz + TIME * wind_speed * normalize(wind_direction.xz)) / wind_noise_scale;
	
	vec3 wind_direction_normalized = normalize(wind_direction);
	vec2 wind_noise_offset = (world_position.xz - TIME * wind_speed * wind_direction_normalized.xz) / wind_noise_scale;
	
	//float noise = texture(wind_noise, world_position.xz / wind_noise_scale + time_offset / wind_noise_scale).r;
	//float noise = texture(wind_noise, (world_position.xz + time_offset) / wind_noise_scale).r;
	float noise = texture(wind_noise, wind_noise_offset).r;
	
	
	ALBEDO = vec3(noise);
}
