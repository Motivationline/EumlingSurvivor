#[versions]
downsample = "#define DOWNSAMPLE";
upsample = "#define UPSAMPLE";
downsample_first_pass = "#define DOWNSAMPLE_FIRST_PASS";
upsample_last_pass = "#define UPSAMPLE_LAST_PASS";
apply = "#define APPLY";

#[vertex]

#version 450

#VERSION_DEFINES

layout(location = 0) out vec2 screen_uv;

void main() {
    float x = float((gl_VertexIndex % 2) * 4); // 0, 4, 0
    float y = float((gl_VertexIndex / 2) * 4); // 0, 0, 4
    gl_Position = vec4(x - 1.0, y - 1.0, 0.0, 1.0); // (-1, -1), (3, -1), (-1, 3)
    screen_uv = vec2(x * 0.5, y * 0.5);  // (0, 0), (2, 0), (0, 2) -> interpolation will yield (0, 0), (1, 0), (0, 1) as the positions are double the size of the screen
}

#[fragment]

#version 450

#VERSION_DEFINES

layout(set = 0, binding = 0) uniform sampler2D color_texture;

layout(location = 0) in vec2 screen_uv;
layout(location = 0) out vec4 frag_color;


#if !defined(APPLY)
layout(push_constant, std430) uniform params {
    vec2 half_pixel_size;
};

vec4 downsample() {
    vec4 sum = texture(color_texture, screen_uv) * 4.0;
    sum += texture(color_texture, screen_uv - half_pixel_size.xy);
    sum += texture(color_texture, screen_uv + half_pixel_size.xy);
    sum += texture(color_texture, screen_uv + vec2(half_pixel_size.x, -half_pixel_size.y));
    sum += texture(color_texture, screen_uv - vec2(half_pixel_size.x, -half_pixel_size.y));

    return sum / 8.0;
}

vec4 upsample() {
  vec4 sum = texture(color_texture, screen_uv + vec2(-half_pixel_size.x * 2.0, 0.0));
  sum += texture(color_texture, screen_uv + vec2(-half_pixel_size.x, half_pixel_size.y)) * 2.0;
  sum += texture(color_texture, screen_uv + vec2(0.0, half_pixel_size.y * 2.0));
  sum += texture(color_texture, screen_uv + vec2(half_pixel_size.x, half_pixel_size.y)) * 2.0;
  sum += texture(color_texture, screen_uv + vec2(half_pixel_size.x * 2.0, 0.0));
  sum += texture(color_texture, screen_uv + vec2(half_pixel_size.x, -half_pixel_size.y)) * 2.0;
  sum += texture(color_texture, screen_uv + vec2(0.0, -half_pixel_size.y * 2.0));
  sum += texture(color_texture, screen_uv + vec2(-half_pixel_size.x, -half_pixel_size.y)) * 2.0;
  return sum / 12.0;
}

vec4 downsample_with_stencil() {
    vec4 samples[5];
    samples[0] = texture(color_texture, screen_uv);
    samples[1] = texture(color_texture, screen_uv - half_pixel_size.xy);
    samples[2] = texture(color_texture, screen_uv + half_pixel_size.xy);
    samples[3] = texture(color_texture, screen_uv + vec2(half_pixel_size.x, -half_pixel_size.y));
    samples[4] = texture(color_texture, screen_uv - vec2(half_pixel_size.x, -half_pixel_size.y));

    vec4 sum = vec4(0.0);
    float weight = 0.0;

    if (samples[0].a == 1.0) {
        sum += samples[0] * 4.0;
        weight += 4.0;
    }

    for (int i = 1; i < 5; i++) {
        if (samples[i].a == 1.0) {
            sum += samples[i];
            weight += 1.0;
        }
    }

    if (weight == 0.0)
        return vec4(1.0, 0.0, 0.0, 0.0);

    return sum / weight;
}

vec4 upsample_with_stencil() {
    vec4 samples[8];
    samples[0] = texture(color_texture, screen_uv + vec2(-half_pixel_size.x, half_pixel_size.y)) * 2.0;
    samples[1] = texture(color_texture, screen_uv + vec2(half_pixel_size.x, half_pixel_size.y)) * 2.0;
    samples[2] = texture(color_texture, screen_uv + vec2(half_pixel_size.x, -half_pixel_size.y)) * 2.0;
    samples[3] = texture(color_texture, screen_uv + vec2(-half_pixel_size.x, -half_pixel_size.y)) * 2.0;
    samples[4] = texture(color_texture, screen_uv + vec2(-half_pixel_size.x * 2.0, 0.0));
    samples[5] = texture(color_texture, screen_uv + vec2(0.0, half_pixel_size.y * 2.0));
    samples[6] = texture(color_texture, screen_uv + vec2(half_pixel_size.x * 2.0, 0.0));
    samples[7] = texture(color_texture, screen_uv + vec2(0.0, -half_pixel_size.y * 2.0));

    vec4 sum = vec4(0.0);
    float weight = 0.0;

    for (int i = 0; i < 4; i++) {
        if (samples[i].a == 1.0) {
            sum += samples[i];
            weight += 2.0;
        }
    }

    for (int i = 4; i < 8; i++) {
        if (samples[i].a == 1.0) {
            sum += samples[i];
            weight += 1.0;
        }
    }

    if (weight == 0.0)
        return vec4(0.0, 1.0, 0.0, 0.0);
    
    return sum / weight;
}

#endif

layout(set=3, binding=0) uniform scene_buffer {
    mat4 inv_projection_matrix;
};

#if defined(DOWNSAMPLE_FIRST_PASS) || defined(APPLY)
layout(set = 1, binding = 0) uniform sampler2D depth_texture;

layout(set=2, binding=0) uniform settings_buffer {
    float far_distance;
    float far_transition;
    float near_distance;
    float near_transition;
    float amount;
};

float get_z() {
    float depth = texture(depth_texture, screen_uv).r;
    vec4 view = inv_projection_matrix * vec4(screen_uv * 2.0 - 1.0, depth, 1.0);
    return -view.z / view.w;
}

vec4 apply() {
    float z = get_z();

	float blur = 0.0f;
	if (z > far_distance)
	 	blur = smoothstep(far_distance, far_distance + far_transition, z);
	else if (z < near_distance)
	 	blur = smoothstep(near_distance, near_distance - near_transition, z);

	blur *= amount;
	
    vec4 color = texture(color_texture, screen_uv);
    color.a = blur;

	return color;
}

#endif

void main() {
#ifdef DOWNSAMPLE_FIRST_PASS
        // vec2 quarter_pixel_size = half_pixel_size * 0.5;

        // float depth0 = texture(depth_texture, screen_uv - quarter_pixel_size).r;
        // float depth1 = texture(depth_texture, screen_uv + quarter_pixel_size).r;
        // float depth2 = texture(depth_texture, screen_uv + vec2(quarter_pixel_size.x, -quarter_pixel_size.y)).r;
        // float depth3 = texture(depth_texture, screen_uv - vec2(quarter_pixel_size.x, -quarter_pixel_size.y)).r;

        // float min_depth = min(min(depth0, depth1), min(depth2, depth3)); // Farther
        // float max_depth = max(max(depth0, depth1), max(depth2, depth3)); // Closer

        // // 3. Unproject max_depth -> z_near (closer to camera)
        // vec4 upos_near = inv_projection_matrix * vec4(screen_uv * 2.0 - 1.0, max_depth, 1.0);
        // float z_near = abs(upos_near.z / upos_near.w);

        // // 4. Unproject min_depth -> z_far (farther from camera)
        // vec4 upos_far = inv_projection_matrix * vec4(screen_uv * 2.0 - 1.0, min_depth, 1.0);
        // float z_far = abs(upos_far.z / upos_far.w);

        // frag_color = vec4(downsample().rgb, z_near > near_distance && z_far < far_distance ? 0.0 : 1.0);

        float z = get_z();

        float blur = 0.0f;
        if (z > far_distance)
            blur = smoothstep(far_distance, far_distance + far_transition, z);
        else if (z < near_distance)
            blur = smoothstep(near_distance, near_distance - near_transition, z);

        blur *= amount;

        frag_color = vec4(downsample().rgb, z > near_distance && z < far_distance ? 0.0 : 1.0);
        
        
#endif

#ifdef DOWNSAMPLE
        frag_color = downsample_with_stencil();
#endif

#ifdef UPSAMPLE
        frag_color = upsample_with_stencil();
#endif

#ifdef APPLY
        frag_color = apply();
        // frag_color = texture(color_texture, screen_uv);
        // frag_color.a = 1.0;
#endif
    
}