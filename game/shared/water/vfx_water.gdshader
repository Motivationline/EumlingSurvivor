// Stylized Water Shader 3D (Godot 4.x, spatial shader)
// Nutze mit einem PlaneMesh oder GridMesh (dicht genug unterteilt für Vertex-Displacement).

shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_opaque;

uniform float time_scale : hint_range(0.0, 8.0) = 1.0;
uniform float speed = 1.0;
uniform float wave_strength = 0.15;
uniform float wave_scale = 2.5;
uniform float noise_scale = 1.8;
uniform float foam_threshold = 0.6;
uniform float foam_amount = 1.2;
uniform float wave_height_limit : hint_range(0.0, 1.0) = 0.5; // Nur obere Vertices bewegen
uniform vec4 deep_color : source_color = vec4(0.02, 0.12, 0.25, 0.6);
uniform vec4 surface_color : source_color = vec4(0.12, 0.5, 0.85, 0.6);
uniform vec4 rim_color : source_color = vec4(0.9, 0.95, 1.0, 0.6);

// Noise-Funktionen (integriert, keine Texturen nötig)
float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash21(i + vec2(0.0,0.0));
    float b = hash21(i + vec2(1.0,0.0));
    float c = hash21(i + vec2(0.0,1.0));
    float d = hash21(i + vec2(1.0,1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float f = 0.0;
    float amp = 0.5;
    for (int i = 0; i < 5; i++) {
        f += amp * noise(p);
        p *= 2.0;
        amp *= 0.5;
    }
    return f;
}

void vertex() {
    float t = TIME * time_scale * speed;
    vec2 uv = UV * wave_scale;
    float n = fbm(uv * noise_scale + vec2(t*0.6, -t*0.4));
    float wave = sin((uv.x + uv.y) * 1.5 + t) * 0.5 + 0.5;
    float offset = (n * 0.7 + wave * 0.3) * wave_strength;

    // Nur Vertices oberhalb der Grenze bewegen
    if (VERTEX.y >= wave_height_limit) {
        VERTEX.y += offset;
    }
}

void fragment() {
    float t = TIME * time_scale * speed;
    vec2 uv = UV * wave_scale;
    float n = fbm(uv * noise_scale + vec2(t*0.5, -t*0.3));

    // Normal-Approximation via Heightfield
    vec3 nrm = normalize(NORMAL + vec3(dFdx(n), 0.0, dFdy(n)) * 2.0);

    // Fresnel-Effekt
    float fresnel = pow(1.0 - clamp(dot(nrm, VIEW), 0.0, 1.0), 3.0);

    // Farbverlauf je nach Höhe
    float depthFade = smoothstep(-1.0, 1.2, VERTEX.y);
    vec3 col = mix(deep_color.rgb, surface_color.rgb, depthFade + n * 0.08);

    // Schaum
    float foam = smoothstep(foam_threshold - 0.05, foam_threshold + 0.05, n + length(dFdx(UV) + dFdy(UV))*0.2);
    foam *= foam_amount;

    // Licht (vereinfacht, stilisiert)
    vec3 light_dir = normalize(vec3(0.3, 1.0, 0.2));
    float ndl = max(dot(nrm, light_dir), 0.0);
    vec3 lit = col * (0.35 + ndl * 0.65);
    lit += rim_color.rgb * fresnel * 0.9;

    // Foam Overlay
    lit = mix(lit, vec3(1.0), clamp(foam, 0.0, 1.0));

    ALBEDO = lit;
    ROUGHNESS = 0.6 - fresnel * 0.4;
    METALLIC = 0.0;
    EMISSION = rim_color.rgb * fresnel * 0.15;
    ALPHA = mix(deep_color.a, surface_color.a, depthFade);
}
