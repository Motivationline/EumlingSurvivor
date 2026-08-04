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

layout(push_constant, std430) uniform params {
    vec2 half_pixel_size;
};

#if !defined(APPLY)

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
        // samples[0].a = 0.0;
        // return samples[0];
        return vec4(1.0, 0.0, 0.0, 0.0);
    }

    return vec4(color / weight, 1.0);
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

    vec3 color = vec3(0.0);
    float weight = 0.0;

    for (int i = 0; i < 4; i++) {
        if (samples[i].a == 1.0) {
            color += samples[i].rgb;
            weight += 2.0;
        }
    }

    for (int i = 4; i < 8; i++) {
        if (samples[i].a == 1.0) {
            color += samples[i].rgb;
            weight += 1.0;
        }
    }

    if (weight == 0.0)
        discard;
    
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

bool is_valid_alpha(float a) {
    // Keep strict behavior but robust to float precision.
    return a > 0.999;
}

vec4 masked_bilinear_lod(sampler2D tex, vec2 uv, int level, out float coverage) {
    ivec2 size_i = textureSize(tex, level);
    vec2 size = vec2(size_i);

    vec2 p = uv * size - 0.5;
    ivec2 b = ivec2(floor(p));
    vec2 f = fract(p);

    ivec2 p00 = clamp(b + ivec2(0, 0), ivec2(0), size_i - ivec2(1));
    ivec2 p10 = clamp(b + ivec2(1, 0), ivec2(0), size_i - ivec2(1));
    ivec2 p01 = clamp(b + ivec2(0, 1), ivec2(0), size_i - ivec2(1));
    ivec2 p11 = clamp(b + ivec2(1, 1), ivec2(0), size_i - ivec2(1));

    vec4 c00 = texelFetch(tex, p00, level);
    vec4 c10 = texelFetch(tex, p10, level);
    vec4 c01 = texelFetch(tex, p01, level);
    vec4 c11 = texelFetch(tex, p11, level);

    float w00 = (1.0 - f.x) * (1.0 - f.y);
    float w10 = f.x * (1.0 - f.y);
    float w01 = (1.0 - f.x) * f.y;
    float w11 = f.x * f.y;

    float m00 = is_valid_alpha(c00.a) ? 1.0 : 0.0;
    float m10 = is_valid_alpha(c10.a) ? 1.0 : 0.0;
    float m01 = is_valid_alpha(c01.a) ? 1.0 : 0.0;
    float m11 = is_valid_alpha(c11.a) ? 1.0 : 0.0;

    float wsum = w00 * m00 + w10 * m10 + w01 * m01 + w11 * m11;
    coverage = wsum;

    if (wsum <= 1e-6) {
        return vec4(0.0, 0.0, 0.0, 0.0);
    }

    vec3 rgb =
        (c00.rgb * (w00 * m00) +
         c10.rgb * (w10 * m10) +
         c01.rgb * (w01 * m01) +
         c11.rgb * (w11 * m11)) / wsum;

    return vec4(rgb, 1.0);
}

vec4 masked_trilinear(sampler2D tex, vec2 uv, float lod) {
    float l = clamp(lod, 0.0, max_lod);

    int l0 = int(floor(l));
    int l1 = min(l0 + 1, int(max_lod));
    float t = fract(l);

    float cov0;
    float cov1;
    vec4 s0 = masked_bilinear_lod(tex, uv, l0, cov0);
    vec4 s1 = masked_bilinear_lod(tex, uv, l1, cov1);

    // Blend lods, but bias by each lod's valid coverage.
    float k0 = (1.0 - t) * cov0;
    float k1 = t * cov1;
    float k = k0 + k1;

    if (k <= 1e-6) {
        return vec4(0.0, 0.0, 0.0, 0.0);
    }

    vec3 rgb = (s0.rgb * k0 + s1.rgb * k1) / k;
    return vec4(rgb, 1.0);
}

vec4 apply() {
    float z = get_z();

	float blur = 0.0f;
	if (z > far_distance)
	 	blur = smoothstep(far_distance, far_distance + far_transition, z);
	else if (z < near_distance)
	 	blur = smoothstep(near_distance, near_distance - near_transition, z);

	blur *= amount;
	
    // vec4 color = texture(color_texture, screen_uv);
    // color.a = blur;

    vec4 color = vec4(
        textureLod(color_texture, screen_uv, max(blur - 1.0, 0.0)).rgb, 
        min(blur, 1.0)
    );
    
    // float lod = max(blur - 1.0, 0.0);
    // vec2 texSize = vec2(textureSize(color_texture, int(lod)));
    // vec2 texelSize = 1.0 / texSize;

    // vec2 texelPos = screen_uv * texSize - 0.5;
    // vec2 base = floor(texelPos);
    // vec2 f = fract(texelPos);

    // vec2 uv00 = (base + vec2(0.5, 0.5)) * texelSize;
    // vec2 uv10 = (base + vec2(1.5, 0.5)) * texelSize;
    // vec2 uv01 = (base + vec2(0.5, 1.5)) * texelSize;
    // vec2 uv11 = (base + vec2(1.5, 1.5)) * texelSize;

    // vec4 c00 = textureLod(color_texture, uv00, lod);
    // vec4 c10 = textureLod(color_texture, uv10, lod);
    // vec4 c01 = textureLod(color_texture, uv01, lod);
    // vec4 c11 = textureLod(color_texture, uv11, lod);

    // float w00 = (1.0 - f.x) * (1.0 - f.y);
    // float w10 = f.x * (1.0 - f.y);
    // float w01 = (1.0 - f.x) * f.y;
    // float w11 = f.x * f.y;

    // vec4 color = vec4(0.0);
    // float totalWeight = 0.0;

    // if (c00.a == 1.0) {
    //     color += c00 * w00;
    //     totalWeight += w00;
    // }

    // if (c10.a == 1.0) {
    //     color += c10 * w10;
    //     totalWeight += w10;
    // }

    // if (c01.a == 1.0) {
    //     color += c01 * w01;
    //     totalWeight += w01;
    // }

    // if (c11.a == 1.0) {
    //     color += c11 * w11;
    //     totalWeight += w11;
    // }

    // if (totalWeight > 0.0)
    //     color /= totalWeight;
    // else
    //     color = vec4(0.0, 0.0, 1.0, 0.0); // or some fallback

    // color.a = min(blur, 1.0);


    // vec4 color = masked_trilinear(color_texture, screen_uv, max(blur - 1.0, 0.0));
    // color.a = min(blur, 1.0);

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
        // float z_near = -upos_near.z / upos_near.w;

        // // 4. Unproject min_depth -> z_far (farther from camera)
        // vec4 upos_far = inv_projection_matrix * vec4(screen_uv * 2.0 - 1.0, min_depth, 1.0);
        // float z_far = -upos_far.z / upos_far.w;

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