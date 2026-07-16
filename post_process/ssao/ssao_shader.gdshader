shader_type spatial;
render_mode unshaded;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

//uniform vec2 ssao_prn_UV;
uniform float ssao_radius_frac;
uniform float ssao_intensity;
// S4AO (Stupid Simple Screen Space Ambient Occlusion) - Jonathan Dummer (O1S)
// This micro version uses only 3 depth samples, the midpoint and a randomly-rotated, balanced pair.

const mediump float ssao_falloff_frac = 0.25;

float quick_hash(vec2 pos) {
	const vec3 magic = vec3(0.06711056f, 0.00583715f, 52.9829189f);
	return fract(magic.z * fract(dot(pos, magic.xy)));
}

// Perform the SSAO.
float s4ao(vec2 uv, vec2 fragcoord) {
	mediump float depth = texture(depth_texture, uv).r;
	mediump float inv_falloff = 1.0f / max(1e-4f, depth * ssao_falloff_frac);
	// Random 2D rotation per pixel (0..1 -> parabola approximating a 180 deg arc)
	//mediump float r01 = fract(dot(uv, ssao_prn_UV));
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

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec3 color = texture(screen_texture, SCREEN_UV).rgb;
	ALBEDO = color * s4ao(SCREEN_UV, FRAGCOORD.xy);
	ALPHA = 1.0;
}