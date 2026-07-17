shader_type spatial;
stencil_mode write, compare_always, 1;
render_mode blend_mix, depth_draw_opaque, cull_back;

#include "cel_shader_include.gdshaderinc"