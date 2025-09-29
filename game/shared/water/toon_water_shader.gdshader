shader_type spatial;

// Umschalten zwischen unshaded (glowy) und lit (mit Licht)
uniform bool unshaded_mode = false; 

// Bewegung / Textur
uniform float slide_speed = 0.3;
uniform float wobble_speed = 1.0;
uniform float wobble_intensity = 0.4;
uniform float texture_scale = 0.2;
uniform sampler2D water : repeat_enable;

uniform sampler2D depth_texture : source_color, hint_depth_texture;

// Gradient-Steuerung für Bewegung
uniform float min_height = -1.0; // Unterkante vom Mesh
uniform float max_height =  1.0; // Oberkante vom Mesh

// Farbverlauf außen
uniform vec3 bottom_color : source_color = vec3(0.2, 0.2, 1.0);
uniform vec3 top_color    : source_color = vec3(1.0, 1.0, 1.0);

// Abdunkeln global
uniform float darken_factor : hint_range(0.0, 1.0) = 0.7;

// Innenkontrolle
uniform vec3 inside_color : source_color = vec3(0.1, 0.1, 0.2);
uniform float inside_darken : hint_range(0.0, 1.0) = 0.8;

varying vec2 sample_choord;
varying float height_factor;

void vertex() {
	// Höhe normalisieren (0 unten, 1 oben)
	height_factor = clamp((VERTEX.y - min_height) / (max_height - min_height), 0.0, 1.0);

	// Bewegung abhängig von Höhe
	float wobble = sin(TIME * wobble_speed + (VERTEX.x + VERTEX.z) * 0.3) * 0.2 * height_factor;
	VERTEX.y += wobble;

	sample_choord = VERTEX.xz;
}

void fragment() {
	// Wassertextur
	vec3 texture_color = texture(
		water,
		vec2(
			(sample_choord.x + sin(TIME * wobble_speed) * wobble_intensity + TIME * slide_speed) * texture_scale,
			(sample_choord.y + cos(TIME * wobble_speed * 0.5) * wobble_intensity) * texture_scale
		)
	).rgb;

	// Farbverlauf außen
	vec3 gradient_color = mix(bottom_color, top_color, height_factor);

	// Kombination aus Verlauf + Textur
	vec3 final_color = mix(gradient_color, texture_color, 0.6);

	// Depth-Mix
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;

	float object_depth = FRAGCOORD.z;
	vec3 object_ndc = vec3(SCREEN_UV * 2.0 - 1.0, object_depth);
	vec4 object_view = INV_PROJECTION_MATRIX * vec4(object_ndc, 1.0);
	object_view.xyz /= object_view.w;
	float linear_object_depth = -object_view.z;

	vec3 depth_mix = mix(vec3(1.0), final_color, smoothstep(0.0, 4.0, linear_depth - linear_object_depth));

	// Abdunkeln
	depth_mix *= darken_factor;

	// Innenfarbe anwenden, falls Rückseite
	if (!FRONT_FACING) {
		depth_mix = mix(depth_mix, inside_color, 0.7); // 0.7 = Stärke der Innenfarbe
		depth_mix *= inside_darken;
	}

	// Unterschied unshaded / lit
	if (unshaded_mode) {
		ALBEDO = depth_mix;
		EMISSION = depth_mix; // Leuchtet selbst
	} else {
		ALBEDO = depth_mix;   // Reagiert auf Licht
	}
}
