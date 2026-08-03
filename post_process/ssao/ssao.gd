@tool
extends CompositorEffect
class_name ssao

var rd: RenderingDevice

var shader: RID
var pipeline: RID

var nearest_sampler: RID

var settings_buffer: RID

var settings: PackedFloat32Array
var settings_dirty: bool = false

var mutex: Mutex = Mutex.new()

@export_range(0.001, 16.0, 0.001) var ssao_radius: float = 0.5:
	set(value):
		ssao_radius = value
		settings_dirty = true

@export_range(0.0, 16.0, 0.001) var ssao_intensity: float = 3.0:
	set(value):
		ssao_intensity = value
		settings_dirty = true

func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_PRE_TRANSPARENT
	rd = RenderingServer.get_rendering_device()
	RenderingServer.call_on_render_thread(_initialize_compute)

	var sampler_state := RDSamplerState.new()
	sampler_state.repeat_u = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	sampler_state.repeat_v = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	nearest_sampler = RenderingServer.get_rendering_device().sampler_create(sampler_state)

	_create_settings_buffer()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if shader.is_valid():
			rd.free_rid(shader)
			
	
func _create_settings_buffer():
	if settings_buffer.is_valid():
		rd.free_rid(settings_buffer)

	settings = PackedFloat32Array([
		ssao_radius,
		ssao_intensity,
		0.0,
		0.0
	])

	var db = PackedByteArray()

	db.append_array(settings.to_byte_array())
	settings_buffer = rd.uniform_buffer_create(db.size(), db)

# Pipeline needs to match the framebuffer_format the device is using
func _create_pipeline(framebuffer_format: int) -> void:
	var rasterization_state = RDPipelineRasterizationState.new()
	var multisample_state = RDPipelineMultisampleState.new()
	var depth_stencil_state = RDPipelineDepthStencilState.new()
	var blend_state = RDPipelineColorBlendState.new()
	
	var blend_attachment = RDPipelineColorBlendStateAttachment.new()
	blend_attachment.enable_blend = true
	blend_attachment.alpha_blend_op = RenderingDevice.BLEND_OP_ADD
	blend_attachment.color_blend_op = RenderingDevice.BLEND_OP_ADD
	blend_attachment.src_color_blend_factor = RenderingDevice.BLEND_FACTOR_DST_COLOR
	blend_attachment.dst_color_blend_factor = RenderingDevice.BLEND_FACTOR_ZERO
	blend_attachment.src_alpha_blend_factor = RenderingDevice.BLEND_FACTOR_DST_ALPHA
	blend_attachment.dst_alpha_blend_factor = RenderingDevice.BLEND_FACTOR_ZERO
	
	blend_state.attachments = [blend_attachment]
	
	pipeline = rd.render_pipeline_create(shader, framebuffer_format, RenderingDevice.INVALID_FORMAT_ID, RenderingDevice.RENDER_PRIMITIVE_TRIANGLES, rasterization_state, multisample_state, depth_stencil_state, blend_state);

	
#region Code in this region runs on the rendering thread.
# Compile our shader at initialization.
func _initialize_compute() -> void:
	rd = RenderingServer.get_rendering_device()
	if not rd:
		return

	# Compile our shader.

	var shader_file := load("res://post_process/ssao/ssao.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()

	shader = rd.shader_create_from_spirv(shader_spirv)


# Called by the rendering thread every frame.
func _render_callback(p_effect_callback_type: EffectCallbackType, p_render_data: RenderData) -> void:
	if not rd:
		return

	# Get our render scene buffers object, this gives us access to our render buffers.
	# Note that implementation differs per renderer hence the need for the cast.
	var render_scene_buffers: RenderSceneBuffersRD = p_render_data.get_render_scene_buffers()

	if not render_scene_buffers:
		return

	# Get our render size, this is the 3D render resolution!
	var size: Vector2i = render_scene_buffers.get_internal_size()
	if size.x == 0 and size.y == 0:
		return
	
	mutex.lock()

	if settings_dirty == true:
		_create_settings_buffer()
		settings_dirty = false
	
	mutex.unlock()

	rd.draw_command_begin_label("SSAO", Color.GREEN)
	
	# Loop through views just in case we're doing stereo rendering. No extra cost if this is mono.
	var view_count: int = render_scene_buffers.get_view_count()
	for view in view_count:
		# Get the RID for our color image, we will be reading from and writing to it.
		var input_image: RID = render_scene_buffers.get_color_layer(view)
		var depth_image: RID = render_scene_buffers.get_depth_layer(view)

		var depth_texture_uniform := RDUniform.new()
		depth_texture_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
		depth_texture_uniform.binding = 0
		depth_texture_uniform.add_id(nearest_sampler)
		depth_texture_uniform.add_id(depth_image)
		var depth_set = UniformSetCacheRD.get_cache(shader, 0, [depth_texture_uniform])
		
		var settings_uniform: RDUniform = RDUniform.new()
		settings_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
		settings_uniform.binding = 0
		settings_uniform.add_id(settings_buffer)
		var scene_set = UniformSetCacheRD.get_cache(shader, 2, [settings_uniform])

		var framebuffer: RID = FramebufferCacheRD.get_cache_multipass([input_image], [], 1)
		var framebuffer_format := rd.framebuffer_get_format(framebuffer)

		if not pipeline.is_valid():
			_create_pipeline(framebuffer_format)
				
		var clear_colors := PackedColorArray()
		var draw_list := rd.draw_list_begin(framebuffer, 0, clear_colors);
		rd.draw_list_bind_render_pipeline(draw_list, pipeline)
		rd.draw_list_bind_uniform_set(draw_list, depth_set, 0)
		rd.draw_list_bind_uniform_set(draw_list, scene_set, 2)
		rd.draw_list_draw(draw_list, false, 1, 3)
		rd.draw_list_end()
			
		rd.draw_command_end_label()

#endregion
