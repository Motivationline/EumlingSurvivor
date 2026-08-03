@tool
class_name depth_of_field_experimental extends CompositorEffect

var rd: RenderingDevice

var dof_shader: RID
var dof_pipeline: RID

var downsample_shader: RID
var downsample_pipeline: RID

var downsample_first_pass_shader: RID
var downsample_first_pass_pipeline: RID

var upsample_shader: RID
var upsample_pipeline: RID

var nearest_sampler: RID
var linear_sampler: RID

var settings_buffer: RID
var scene_buffer: RID

var framebuffer_size: Vector2i = Vector2i(0, 0)

var screen_textures: Array[RID]
var screen_textures_dirty: bool = true
var screen_texture_levels: int = 6:
	set(value):
		if value == screen_texture_levels: return
		screen_texture_levels = value
		screen_textures_dirty = true

var push_constant: PackedFloat32Array = PackedFloat32Array([0.0, 0.0])

var settings: PackedFloat32Array
var settings_dirty: bool = true

var scene_dirty: bool = true

var mutex: Mutex = Mutex.new()

@export_range(0.001, 8192.0, 0.01, "exp", "suffix:m") var far_distance: float = 10.0:
	set(value):
		far_distance = value
		settings_dirty = true

@export_range(0.001, 8192.0, 0.01, "exp", "suffix:m") var far_transition: float = 5.0:
	set(value):
		far_transition = value
		settings_dirty = true

@export_range(0.001, 8192.0, 0.01, "exp", "suffix:m") var near_distance: float = 2.0:
	set(value):
		near_distance = value
		settings_dirty = true

@export_range(0.001, 8192.0, 0.01, "exp", "suffix:m") var near_transition: float = 1.0:
	set(value):
		near_transition = value
		settings_dirty = true

@export_range(0.0, 1.0, 0.001) var amount: float = 0.35:
	set(value):
		amount = value
		settings_dirty = true

func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()
	RenderingServer.call_on_render_thread(_initialize_compute)

	var sampler_state := RDSamplerState.new()
	sampler_state.repeat_u = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	sampler_state.repeat_v = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	nearest_sampler = RenderingServer.get_rendering_device().sampler_create(sampler_state)

	var sampler_state_linear := RDSamplerState.new()
	sampler_state_linear.repeat_u = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	sampler_state_linear.repeat_v = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	sampler_state_linear.min_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	sampler_state_linear.mag_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	linear_sampler = RenderingServer.get_rendering_device().sampler_create(sampler_state_linear)

	amount = amount # trigger setter

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if dof_shader.is_valid():
			rd.free_rid(dof_shader)

		if downsample_shader.is_valid():
			rd.free_rid(downsample_shader)

		if downsample_first_pass_shader.is_valid():
			rd.free_rid(downsample_first_pass_shader)

		if upsample_shader.is_valid():
			rd.free_rid(upsample_shader)
			
func _create_settings_buffer():
	if settings_buffer.is_valid():
		rd.free_rid(settings_buffer)

	settings = PackedFloat32Array([
		far_distance,
		far_transition,
		near_distance,
		near_transition,
		amount,
		0.0,
		0.0,
		0.0
	])

	var db = PackedByteArray()

	db.append_array(settings.to_byte_array())
	settings_buffer = rd.uniform_buffer_create(db.size(), db)

func _create_scene_buffer(render_scene_data):
	if scene_buffer.is_valid():
		rd.free_rid(scene_buffer)

	var cam = render_scene_data.get_cam_projection()

	var cam_mat = [
		cam.x.x, cam.x.y, cam.x.z, cam.x.w,
		cam.y.x, cam.y.y, cam.y.z, cam.y.w,
		cam.z.x, cam.z.y, cam.z.z, cam.z.w,
		cam.w.x, cam.w.y, cam.w.z, cam.w.w,
	]

	var cma = PackedFloat32Array(cam_mat).to_byte_array()

	var pb = PackedByteArray()
	pb.append_array(cma)

	scene_buffer = rd.uniform_buffer_create(pb.size(), pb)

# func _create_textures(color_format: RenderingDevice.DataFormat, size: Vector2i) -> void:
# 	var half_screen_texture = RDTextureFormat.new()
# 	half_screen_texture.format = color_format
# 	half_screen_texture.width = size.x / 2
# 	half_screen_texture.height = size.y / 2
# 	half_screen_texture.depth = 1
# 	half_screen_texture.mipmaps = screen_texture_levels
# 	half_screen_texture.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT + RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT

# 	screen_texture = rd.texture_create(half_screen_texture, RDTextureView.new())

# 	screen_textures = [RID()] # index 0 is reserved for the full screen image
# 	screen_textures.resize(1 + screen_texture_levels)
# 	for i in range(1, screen_textures.size()):
# 		screen_textures[i] = rd.texture_create_shared_from_slice(RDTextureView.new(), screen_texture, 0, i - 1) # create texture views into mip levels

func _create_textures(color_format: RenderingDevice.DataFormat, size: Vector2i) -> void:
	screen_textures = [RID()] # index 0 is reserved for the full screen image
	screen_textures.resize(1 + screen_texture_levels)

	print("Create Textures " + str(screen_texture_levels))

	var target_size: Vector2
	for i in range(1, screen_textures.size()):
		target_size = size / (2 ** i)

		var texture = RDTextureFormat.new()
		texture.format = color_format
		texture.width = target_size.x
		texture.height = target_size.y
		texture.depth = 1
		texture.mipmaps = 1
		texture.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT + RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT
		screen_textures[i] = rd.texture_create(texture, RDTextureView.new())

func _clean_textures() -> void:
	for i in range(1, screen_textures.size()):
		if screen_textures[i].is_valid():
			rd.free_rid(screen_textures[i])

	screen_textures.clear()

# Pipeline needs to match the framebuffer_format the device is using
func _create_pipeline(shader: RID, framebuffer_format: int, blend_attachment: RDPipelineColorBlendStateAttachment) -> RID:
	var rasterization_state = RDPipelineRasterizationState.new()
	var multisample_state = RDPipelineMultisampleState.new()
	var depth_stencil_state = RDPipelineDepthStencilState.new()
	var blend_state = RDPipelineColorBlendState.new()
	blend_state.attachments = [blend_attachment]
	
	return rd.render_pipeline_create(shader, framebuffer_format, RenderingDevice.INVALID_FORMAT_ID, RenderingDevice.RENDER_PRIMITIVE_TRIANGLES, rasterization_state, multisample_state, depth_stencil_state, blend_state);

func _create_pipeline_blend_mix(shader: RID, framebuffer_format: int) -> RID:
	var attachment = RDPipelineColorBlendStateAttachment.new()
	attachment.set_as_mix()

	return _create_pipeline(shader, framebuffer_format, attachment)

func _create_pipeline_blend_disabled(shader: RID, framebuffer_format: int) -> RID:
	var attachment = RDPipelineColorBlendStateAttachment.new()
	attachment.enable_blend = false;
	return _create_pipeline(shader, framebuffer_format, attachment)

func _create_pipeline_upsample(shader: RID, framebuffer_format: int) -> RID:
	var attachment = RDPipelineColorBlendStateAttachment.new()
	attachment.enable_blend = false;
	attachment.write_a = false;

	# attachment.color_blend_op = RenderingDevice.BLEND_OP_ADD
	# attachment.src_color_blend_factor = RenderingDevice.BLEND_FACTOR_DST_ALPHA
	# attachment.dst_color_blend_factor = RenderingDevice.BLEND_FACTOR_ONE_MINUS_DST_ALPHA

	# attachment.alpha_blend_op = RenderingDevice.BLEND_OP_ADD
	# attachment.src_alpha_blend_factor = RenderingDevice.BLEND_FACTOR_ONE
	# attachment.dst_alpha_blend_factor = RenderingDevice.BLEND_FACTOR_ONE_MINUS_SRC_ALPHA
	return _create_pipeline(shader, framebuffer_format, attachment)

	
#region Code in this region runs on the rendering thread.
# Compile our dof_shader at initialization.
func _initialize_compute() -> void:
	rd = RenderingServer.get_rendering_device()
	if not rd:
		return

	var shader_file: RDShaderFile = load("res://post_process/depth_of_field/depth_of_field_experimental.glsl")

	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv("downsample")
	downsample_shader = rd.shader_create_from_spirv(shader_spirv)

	shader_spirv = shader_file.get_spirv("downsample_first_pass")
	downsample_first_pass_shader = rd.shader_create_from_spirv(shader_spirv)

	shader_spirv = shader_file.get_spirv("upsample")
	upsample_shader = rd.shader_create_from_spirv(shader_spirv)

	shader_spirv = shader_file.get_spirv("apply")
	dof_shader = rd.shader_create_from_spirv(shader_spirv)


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

	if size != framebuffer_size:
		framebuffer_size = size
		screen_textures_dirty = true

	if settings_dirty == true:
		_create_settings_buffer()
		settings_dirty = false
	
	mutex.unlock()

	rd.draw_command_begin_label("DOF", Color.YELLOW)
	
	# Loop through views just in case we're doing stereo rendering. No extra cost if this is mono.
	var view_count: int = render_scene_buffers.get_view_count()
	var render_scene_data = p_render_data.get_render_scene_data()
	for view in view_count:
		# Get the RID for our color image, we will be reading from and writing to it.
		var input_image: RID = render_scene_buffers.get_color_layer(view)
		var input_framebuffer: RID = FramebufferCacheRD.get_cache_multipass([input_image], [], 1)
		var input_framebuffer_format := rd.framebuffer_get_format(input_framebuffer)
		var input_texture_format: RDTextureFormat = rd.texture_get_format(input_image)
		var input_texture_color_format: RenderingDevice.DataFormat = input_texture_format.format

		var depth_image: RID = render_scene_buffers.get_depth_layer(view)

		# textures and pipelines need to match formats of the device
		if screen_textures_dirty:
			_clean_textures()
			_create_textures(input_texture_color_format, size)
			screen_textures_dirty = false

		if not downsample_pipeline.is_valid():
			downsample_pipeline = _create_pipeline_blend_disabled(downsample_shader, input_framebuffer_format)

		if not downsample_first_pass_pipeline.is_valid():
			downsample_first_pass_pipeline = _create_pipeline_blend_disabled(downsample_first_pass_shader, input_framebuffer_format)

		if not upsample_pipeline.is_valid():
			upsample_pipeline = _create_pipeline_upsample(upsample_shader, input_framebuffer_format)

		if not dof_pipeline.is_valid():
			dof_pipeline = _create_pipeline_blend_mix(dof_shader, input_framebuffer_format)

		var depth_texture_uniform := RDUniform.new()
		depth_texture_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
		depth_texture_uniform.binding = 0
		depth_texture_uniform.add_id(nearest_sampler)
		depth_texture_uniform.add_id(depth_image)

		if scene_dirty == true:
			_create_scene_buffer(render_scene_data)
			scene_dirty = false

		var scene_uniform: RDUniform = RDUniform.new()
		scene_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
		scene_uniform.binding = 0
		scene_uniform.add_id(scene_buffer)

		var settings_uniform: RDUniform = RDUniform.new()
		settings_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
		settings_uniform.binding = 0
		settings_uniform.add_id(settings_buffer)

		screen_textures[0] = input_image;

		for i in range(1, screen_textures.size()):
			var color_uniform := RDUniform.new()
			color_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
			color_uniform.binding = 0
			color_uniform.add_id(linear_sampler)
			color_uniform.add_id(screen_textures[i - 1])

			var target_size: Vector2 = size / (2 ** i)
			push_constant.set(0, 0.5 / target_size.x)
			push_constant.set(1, 0.5 / target_size.y)

			var first_pass: bool = i == 1;
			var pipeline: RID = downsample_pipeline
			var shader: RID = downsample_shader
			if (first_pass):
				pipeline = downsample_first_pass_pipeline
				shader = downsample_first_pass_shader

			var downsample_framebuffer = FramebufferCacheRD.get_cache_multipass([screen_textures[i]], [], 1)
			var downsample_draw_list := rd.draw_list_begin(downsample_framebuffer, RenderingDevice.DRAW_IGNORE_ALL);
			rd.draw_list_bind_render_pipeline(downsample_draw_list, pipeline)

			rd.draw_list_set_push_constant(downsample_draw_list, push_constant.to_byte_array(), push_constant.size() * 4)
			rd.draw_list_bind_uniform_set(downsample_draw_list, UniformSetCacheRD.get_cache(shader, 0, [color_uniform]), 0)

			if (first_pass):
				rd.draw_list_bind_uniform_set(downsample_draw_list, UniformSetCacheRD.get_cache(shader, 1, [depth_texture_uniform]), 1)
				rd.draw_list_bind_uniform_set(downsample_draw_list, UniformSetCacheRD.get_cache(shader, 2, [settings_uniform]), 2)

			rd.draw_list_bind_uniform_set(downsample_draw_list, UniformSetCacheRD.get_cache(shader, 3, [scene_uniform]), 3)

			rd.draw_list_draw(downsample_draw_list, false, 1, 3)
			rd.draw_list_end()

		for i in range(screen_textures.size() - 1, 1, -1):
			var color_uniform := RDUniform.new()
			color_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
			color_uniform.binding = 0
			color_uniform.add_id(linear_sampler)
			color_uniform.add_id(screen_textures[i])

			var target_size: Vector2 = size / (2 ** (i - 1))
			push_constant.set(0, 0.5 / target_size.x)
			push_constant.set(1, 0.5 / target_size.y)

			var pipeline: RID = upsample_pipeline
			var shader: RID = upsample_shader

			var upsample_framebuffer = FramebufferCacheRD.get_cache_multipass([screen_textures[i - 1]], [], 1)
			var upsample_draw_list := rd.draw_list_begin(upsample_framebuffer, RenderingDevice.DRAW_IGNORE_ALL);
			rd.draw_list_bind_render_pipeline(upsample_draw_list, pipeline)

			rd.draw_list_set_push_constant(upsample_draw_list, push_constant.to_byte_array(), push_constant.size() * 4)
			rd.draw_list_bind_uniform_set(upsample_draw_list, UniformSetCacheRD.get_cache(shader, 0, [color_uniform]), 0)

			rd.draw_list_bind_uniform_set(upsample_draw_list, UniformSetCacheRD.get_cache(shader, 3, [scene_uniform]), 3)

			rd.draw_list_draw(upsample_draw_list, false, 1, 3)
			rd.draw_list_end()

		var color_texture_uniform := RDUniform.new()
		color_texture_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
		color_texture_uniform.binding = 0
		color_texture_uniform.add_id(linear_sampler)
		color_texture_uniform.add_id(screen_textures[1])
		
		var clear_colors := PackedColorArray()
		var dof_draw_list := rd.draw_list_begin(input_framebuffer, 0, clear_colors);
		rd.draw_list_bind_render_pipeline(dof_draw_list, dof_pipeline)
		rd.draw_list_bind_uniform_set(dof_draw_list, UniformSetCacheRD.get_cache(dof_shader, 0, [color_texture_uniform]), 0)
		rd.draw_list_bind_uniform_set(dof_draw_list, UniformSetCacheRD.get_cache(dof_shader, 1, [depth_texture_uniform]), 1)
		rd.draw_list_bind_uniform_set(dof_draw_list, UniformSetCacheRD.get_cache(dof_shader, 2, [settings_uniform]), 2)
		rd.draw_list_bind_uniform_set(dof_draw_list, UniformSetCacheRD.get_cache(dof_shader, 3, [scene_uniform]), 3)
		rd.draw_list_draw(dof_draw_list, false, 1, 3)
		rd.draw_list_end()
			
		rd.draw_command_end_label()

#endregion
