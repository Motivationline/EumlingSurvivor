shader_type spatial;

group_uniforms appearance;
uniform sampler2D albedo_texture : source_color;
uniform float metallic : hint_range(0.0, 1.0, 0.01);
uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float roughness : hint_range(0.0, 1.0);
group_uniforms;

#include "wind_foliage_shader_include.gdshaderinc"

void fragment() {
	ALBEDO = texture(albedo_texture, UV).rgb;
	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;
	// ALBEDO = COLOR.rgb; // for debugging
}
