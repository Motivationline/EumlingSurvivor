#[versions]
downsample = "#define DOWNSAMPLE";
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

#ifdef DOWNSAMPLE

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

#endif

#ifdef APPLY

    layout(set = 1, binding = 0) uniform sampler2D depth_texture;

    layout(set = 2, binding = 0) uniform settings_buffer {
        float far_distance;
        float far_transition;
        float near_distance;
        float near_transition;
        float amount;
    };

    layout(set = 3, binding = 0) uniform scene_buffer {
        mat4 inv_projection_matrix;
    };

    vec4 dof() {
        float depth = texture(depth_texture, screen_uv).r;
        vec4 upos = inv_projection_matrix * vec4(screen_uv * 2.0f - 1.0f, depth, 1.0f);
        float z = abs(upos.z / upos.w);

        float blur = 0.0f;
        if (z > far_distance)
            blur = smoothstep(far_distance, far_distance + far_transition, z);
        else if (z < near_distance)
            blur = smoothstep(near_distance, near_distance - near_transition, z);

        blur *= amount;
        
        // vec4 color;
        // if (blur < 1.0) {
        //     color = texture(color_texture, screen_uv);
        //     color.a = blur;
        // } else {
        //     color = textureLod(color_texture, screen_uv, blur - 1.0);
        //     color.a = 1.0;
        // }

        // return color;
        
        return vec4(
            textureLod(color_texture, screen_uv, max(blur - 1.0, 0.0)).rgb, 
            min(blur, 1.0)
        );
    }

#endif



void main() {
    
    #ifdef APPLY
        frag_color = dof();
    #endif

    #ifdef DOWNSAMPLE
        frag_color = downsample();
    #endif

}
