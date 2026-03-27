shader_type spatial;
render_mode cull_disabled, diffuse_lambert, specular_disabled;

const vec3 UP = vec3(0.0, 1.0, 0.0);

const float MAX_BEND_ANGLE = 90.0;
const float MAX_BEND_ANGLE_RAD = radians(MAX_BEND_ANGLE);

group_uniforms appearance;

uniform vec3 backlight: source_color = vec3(0.5);

uniform vec4 color_tip: source_color = vec4(0.26, 0.70, 0.19, 1.0);
uniform vec4 color_base: source_color = vec4(0.11, 0.33, 0.08, 1.0);

uniform float blade_bend_angle: hint_range(0, MAX_BEND_ANGLE, 0.1) = 15.0;
uniform float blade_width = 0.15;
group_uniforms;

group_uniforms variation;
uniform sampler2D variation_noise;
uniform float variation_noise_scale = 5.0;
uniform float blade_size_min = 0.4;
uniform float blade_size_max = 0.6;
group_uniforms;

group_uniforms wind;
uniform sampler2D wind_noise;
uniform float wind_noise_scale = 10.0;
uniform vec3 wind_direction = vec3(1.0, 0.0, 0.0);
uniform float wind_speed: hint_range(0, 2.0, 0.001) = 0.1;
uniform float wind_bend_angle: hint_range(0, MAX_BEND_ANGLE, 0.1) = 35.0;
group_uniforms;

varying float height_factor;

mat3 mat3_from_axis_angle(vec3 axis, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	float t = 1.0 - c;
	float x = axis.x;
	float y = axis.y;
	float z = axis.z;
	return mat3(
		vec3(t*x*x+c, t*x*y-s*z, t*x*z+s*y),
		vec3(t*x*y+s*z, t*y*y+c, t*y*z-s*x),
		vec3(t*x*z-s*y, t*y*z+s*z, t*z*z+c)
	);
}

void vertex() {
	height_factor = VERTEX.y;
	VERTEX.xz *= blade_width;

	float patch_factor = texture(variation_noise, NODE_POSITION_WORLD.xz / variation_noise_scale).x;
	VERTEX *= mix(blade_size_min, blade_size_max, patch_factor);

	COLOR = mix(color_base, color_tip, height_factor);

	float blade_bend_angle_rad = radians(blade_bend_angle);
	float s = sin(blade_bend_angle_rad);
	float c = cos(blade_bend_angle_rad);
	mat3 forward_rot = mat3(
		vec3(1.0, 0.0, 0.0),
		vec3(0.0, c, s),
		vec3(0.0, -s, c)
	);

	mat3 model_bend = mat3(MODEL_MATRIX) * forward_rot;
	mat3 inv_model_bend = transpose(model_bend);

	vec3 wind_forward = normalize(wind_direction);
	vec3 wind_right = cross(wind_forward, vec3(0.0, 1.0, 0.0));

	vec3 model_up = normalize(model_bend[1].xyz);
	vec3 up_proj = model_up - wind_right * dot(model_up, wind_right);
	float alignment = dot(normalize(up_proj), wind_forward);
	float angle = acos(alignment);
	float tilt_factor = clamp(angle / MAX_BEND_ANGLE_RAD, 0.0, 1.0);

	vec2 wind_uv = NODE_POSITION_WORLD.xz / wind_noise_scale;
	wind_uv -= wind_forward.xz * TIME * wind_speed;
	float wind_strength = texture(wind_noise, wind_uv).x;

	float wind_bend_angle_rad = radians(wind_bend_angle) * tilt_factor;
	wind_right = inv_model_bend * wind_right;

	mat3 wind_rot_right = mat3_from_axis_angle(wind_right, wind_bend_angle_rad * wind_strength);
	mat3 bend_rot = forward_rot * wind_rot_right;

	if (height_factor > 0.0)
		VERTEX = bend_rot * VERTEX;

	NORMAL = bend_rot * NORMAL;
}

void fragment() {
	ALBEDO = COLOR.rgb;
	BACKLIGHT = backlight;
	NORMAL = mix(NORMAL, UP, height_factor);
}