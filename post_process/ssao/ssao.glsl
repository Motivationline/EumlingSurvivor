#[vertex]

#version 450

layout(location = 0) out vec2 screen_uv;

void main() {
    float x = float((gl_VertexIndex % 2) * 4); // 0, 4, 0
    float y = float((gl_VertexIndex / 2) * 4); // 0, 0, 4
    gl_Position = vec4(x - 1.0, y - 1.0, 0.0, 1.0); // (-1, -1), (3, -1), (-1, 3)
    screen_uv = vec2(x * 0.5, y * 0.5);  // (0, 0), (2, 0), (0, 2) -> interpolation will yield (0, 0), (1, 0), (0, 1) as the positions are double the size of the screen
}

#[fragment]

#version 450

layout(set = 0, binding = 0) uniform sampler2D depth_texture;

layout(location = 0) in vec2 screen_uv;
layout(location = 0) out vec4 frag_color;

layout(set=2, binding=0) uniform SettingsBuffer {
    float ssao_radius_frac;
    float ssao_intensity;
};

const vec3 magic = vec3(0.06711056f, 0.00583715f, 52.9829189f);
float quick_hash(vec2 pos) {
	return fract(magic.z * fract(dot(pos, magic.xy)));
}

// adjusted from S4AO (Stupid Simple Screen Space Ambient Occlusion) - Jonathan Dummer (O1S)
const mediump float ssao_falloff_frac = 0.25;
float s4ao(vec2 uv, vec2 fragcoord) {
	mediump float depth = texture(depth_texture, uv).r;
	mediump float inv_falloff = 1.0f / max(1e-4f, depth * ssao_falloff_frac);
	// Random 2D rotation per pixel (0..1 -> parabola approximating a 180 deg arc)
	mediump float r01 = quick_hash(fragcoord);
	
	mediump vec2 duv = vec2(r01 - 0.5f, 2.0f * (r01 - r01 * r01)) * (2.0f * depth * ssao_radius_frac); // 180 degrees.
	// Grab the samples and determine the occlusion.
	mediump float occlusion = 0.0f;
	for (int s = 0; s < 2; ++s) {
		mediump float dz = texture(depth_texture, uv + duv).r - depth;
		// How 'directly overhead' is it?  Factor in the falloff depth.
		occlusion += normalize(vec3(duv, dz)).z * mix(1.0f, 0.0f, dz * inv_falloff);
		// Mirror the next sample.
		duv = -duv;
	}
	// Adjust the occlusion for intensity, and # samples.
	occlusion = 1.0f - clamp(occlusion * 0.5f * ssao_intensity, 0.0f, 1.0f);

	return occlusion * occlusion;
}

void main() {
    float occlusion = s4ao(screen_uv, gl_FragCoord.xy);
    frag_color = vec4(occlusion, occlusion, occlusion, 1.0);
}
