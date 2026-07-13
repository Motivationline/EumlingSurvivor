#include "wind_global_uniforms.gdshaderinc"

group_uniforms wind;
/** How much the plant is influenced by the wind. */
uniform float wind_influence = 1.0; 
/** Distance where the plant begins to be influenced by the wind. */
uniform float wind_influence_start : hint_range(0.0, 1.0, 0.01) = 0.01;
/** Distance where the plant reaches maximum wind influence. */
uniform float wind_influence_end : hint_range(0.0, 2.0, 0.01) = 1.0;
group_uniforms;

group_uniforms mesh;
/** The aabb size of the mesh. */
uniform vec3 mesh_aabb_size;
/** The origin-centered bounding radius of the mesh. */
uniform float mesh_bounding_radius;
group_uniforms;

float inverseLerp(float a, float b, float v) {
	return clamp(( v - a ) / ( b - a ), 0.0, 1.0);
}

float rootMeanSquare(vec3 v) {
	return sqrt((v.x * v.x + v.y * v.y + v.z * v.z) / 3.0);
}

void vertex() {
	vec3 direction_normalized = normalize(wind_direction);

	vec2 noise_uv = (NODE_POSITION_WORLD.xz - TIME * wind_speed * direction_normalized.xz) * wind_frequency;
	float noise = texture(wind_noise, noise_uv).r;
    
	vec3 world_aabb_size = mesh_aabb_size * vec3(length(MODEL_MATRIX[0]), length(MODEL_MATRIX[1]), length(MODEL_MATRIX[2]));
	float foliage_size = rootMeanSquare(world_aabb_size); // maximum displacement based on the aabb size of the mesh
	// float foliage_size = mesh_bounding_radius * length(MODEL_MATRIX[0]); // assuming uniform scaling

	float distance_normalized = length(VERTEX) / mesh_bounding_radius;
    float distance_factor = inverseLerp(wind_influence_start, wind_influence_end, distance_normalized);
	
	float displacement = noise * wind_strength * wind_influence * distance_factor * foliage_size;
	
	mat3 inv_model = inverse(mat3(MODEL_MATRIX));
	vec3 direction = inv_model * direction_normalized;
	
    VERTEX.x += direction.x * displacement;
    VERTEX.z += direction.z * displacement;

    // COLOR = vec4(distance_factor * resistance_factor); // for debugging, visualize the distance factor and resistance factor as vertex color
}