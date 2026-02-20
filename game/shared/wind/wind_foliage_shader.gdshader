shader_type spatial;

group_uniforms appearance;
uniform sampler2D albedo_texture : source_color;
uniform float metallic : hint_range(0.0, 1.0, 0.01);
uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float roughness : hint_range(0.0, 1.0);
group_uniforms;

global uniform sampler2D wind_noise;
global uniform float wind_noise_scale;
global uniform float wind_speed;
global uniform float wind_strength; // between 0 and 1, controls how much the wind affects the foliage
global uniform vec3 wind_direction;

group_uniforms wind;
uniform float wind_influence_start = 0.5;
uniform float wind_influence_end = 3.0;
uniform float stiffness : hint_range(0.0, 1.0, 0.01) = 0.5; // controls the maximum displacement of vertices, 0 = max displacment is the length of the aabb size of the mesh in local space, 1 = no displacement
uniform vec3 size = vec3(1.0); // aabb size of the mesh in local space
uniform vec3 scaled_size = vec3(1.0); // aabb size of the mesh in local space
group_uniforms;

float inverseLerp(float a, float b, float v) {
	return clamp(( v - a ) / ( b - a ), 0.0, 1.0);
}

void vertex() {
	vec3 wind_direction_normalized = normalize(wind_direction);

	vec2 wind_noise_offset = (NODE_POSITION_WORLD.xz - TIME * wind_speed * wind_direction_normalized.xz) / wind_noise_scale;
	float noise = texture(wind_noise, wind_noise_offset).r;
    
	vec3 world_size = size * vec3(length(MODEL_MATRIX[0]), length(MODEL_MATRIX[1]), length(MODEL_MATRIX[2]));
	float world_length = length(world_size);
	float displacement = noise * wind_strength * world_length;
	
	float distance = length(VERTEX);
	float distance_factor = inverseLerp(wind_influence_start, wind_influence_end, distance);

	float resistance_factor = 1.0 - stiffness;
	displacement = displacement * distance_factor * resistance_factor;
	
	mat3 inv_model = inverse(mat3(MODEL_MATRIX));
	vec3 direction = inv_model * wind_direction_normalized;
	
    VERTEX.x += direction.x * displacement;
    VERTEX.z += direction.z * displacement;

    //COLOR = vec4(distance_factor * resistance_factor);
}

void fragment() {
	ALBEDO = texture(albedo_texture, UV).rgb;
	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;
	//ALBEDO = COLOR.rgb;
}


