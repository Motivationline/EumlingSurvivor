shader_type spatial;
render_mode blend_mix, cull_back;

// Umschalten zwischen unshaded (glowy) und lit (mit Licht)
uniform bool unshaded_mode = false;

// Bewegung
uniform float wobble_speed = 1.0;
uniform float wobble_intensity = 0.4;
uniform float wobble_scale = 0.3; // Dichte / Wellenfrequenz

// Gradient-Steuerung für Bewegung (nur für Vertex-Wellen)
uniform float min_height = -1.0;
uniform float max_height =  1.0;

// Farbverlauf unten/oben steuerbar über gradient_factor
uniform float gradient_factor : hint_range(0.0, 1.0) = 0.5;
uniform vec3 bottom_color : source_color = vec3(0.2, 0.2, 1.0);
uniform vec3 top_color    : source_color = vec3(1.0, 1.0, 1.0);

// Abdunkeln global
uniform float darken_factor : hint_range(0.0, 1.0) = 0.7;

// Innenkontrolle
uniform vec3 inside_color : source_color = vec3(0.1, 0.1, 0.2);
uniform float inside_darken : hint_range(0.0, 1.0) = 0.8;

// Transparenz separat steuern
uniform float alpha_value : hint_range(0.0,1.0) = 0.5;

varying float height_factor;

void vertex() {
    // Höhe normalisieren für Bewegung
    height_factor = clamp((VERTEX.y - min_height) / (max_height - min_height), 0.0, 1.0);

    // Bewegung abhängig von Höhe (nur Vertices zwischen min_height und max_height)
    float wobble = sin(TIME * wobble_speed + (VERTEX.x + VERTEX.z) * wobble_scale) * wobble_intensity * height_factor;
    VERTEX.y += wobble;
}

void fragment() {
    // Farbverlauf basierend auf Vertex-Höhe und gradient_factor
    float grad = mix(0.0, 1.0, height_factor); // Basis Gradient von unten nach oben
    grad = mix(grad, gradient_factor, 0.5); // Einfluss von gradient_factor
    vec3 gradient_color = mix(bottom_color, top_color, grad);

    vec3 final_color = gradient_color;

    // Abdunkeln
    final_color *= darken_factor;

    // Innenfarbe anwenden, falls Rückseite
    if (!FRONT_FACING) {
        final_color = mix(final_color, inside_color, 0.7);
        final_color *= inside_darken;
    }

    // Unterschied unshaded / lit
    if (unshaded_mode) {
        ALBEDO = final_color;
        EMISSION = final_color;
    } else {
        ALBEDO = final_color;
    }

    // Transparenz separat steuern
    ALPHA = alpha_value;
}
