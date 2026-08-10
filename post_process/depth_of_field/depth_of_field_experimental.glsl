#[versions]
downsample = "#define DOWNSAMPLE";
downsample_first_pass = "#define DOWNSAMPLE_FIRST_PASS";
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

#if defined(DOWNSAMPLE_FIRST_PASS) || defined(DOWNSAMPLE)

    layout(push_constant, std430) uniform params {
        vec2 sample_size;
    };

#endif

#if defined(DOWNSAMPLE_FIRST_PASS)

    vec4 downsample() {
        vec4 sum = texture(color_texture, screen_uv) * 4.0;
        sum += texture(color_texture, screen_uv - sample_size.xy);
        sum += texture(color_texture, screen_uv + sample_size.xy);
        sum += texture(color_texture, screen_uv + vec2(sample_size.x, -sample_size.y));
        sum += texture(color_texture, screen_uv - vec2(sample_size.x, -sample_size.y));

        return sum / 8.0;
    }

#endif

#if defined(DOWNSAMPLE)

    vec4 downsample() {
        vec4 samples[5];
        samples[0] = texture(color_texture, screen_uv);
        samples[1] = texture(color_texture, screen_uv - sample_size.xy);
        samples[2] = texture(color_texture, screen_uv + sample_size.xy);
        samples[3] = texture(color_texture, screen_uv + vec2(sample_size.x, -sample_size.y));
        samples[4] = texture(color_texture, screen_uv - vec2(sample_size.x, -sample_size.y));

        vec3 color = vec3(0.0);
        float weight = 0.0;

        if (samples[0].a == 1.0) {
            color += samples[0].rgb * 4.0;
            weight += 4.0;
        }

        for (int i = 1; i < 5; i++) {
            if (samples[i].a == 1.0) {
                color += samples[i].rgb;
                weight += 1.0;
            }
        }

        if (weight == 0.0) {
            return vec4(samples[0].rgb, 0.0);
        }

        return vec4(color / weight, 1.0);
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
    float max_lod;
};

float get_z() {
    float depth = texture(depth_texture, screen_uv).r;
    vec4 view = inv_projection_matrix * vec4(screen_uv * 2.0 - 1.0, depth, 1.0);
    return -view.z / view.w;
}

vec4 apply() {
    float z = get_z();

	float blur = 0.0;
	if (z > far_distance)
	 	blur = smoothstep(far_distance, far_distance + far_transition, z);
	else if (z < near_distance)
	 	blur = smoothstep(near_distance, near_distance - near_transition, z);

	blur *= amount;

    vec4 color = vec4(
        textureLod(color_texture, screen_uv, max(blur - 1.0, 0.0)).rgb, 
        min(blur, 1.0)
    );

	return color;
}

#endif

void main() {

    #ifdef DOWNSAMPLE_FIRST_PASS

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

        frag_color = downsample();

    #endif

    #ifdef APPLY

        frag_color = apply();
        // frag_color = texture(color_texture, screen_uv);
        // frag_color.a = 1.0;

    #endif
    
}