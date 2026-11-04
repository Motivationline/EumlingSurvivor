extends Node

var scale := 1.0
var step := 0.12

var panic_frames := 2
var panic_counter := 0
var panic_threshold := 0.90

var recovery_frames := 60
var recovery_counter := 0
var recovery_threshold := 0.75

func _ready():
	GraphicsSettings.setting_changed.connect(on_setting_changed)
	toggle(is_same(GraphicsSettings.get_setting(GraphicsSettings.SETTING.DYNAMIC_RENDER_SCALE), GraphicsSettings.DYNAMIC_RENDER_SCALE.ON))

func _process(_delta):
	var gpu_frame_time = RenderingServer.viewport_get_measured_render_time_gpu(
		get_viewport().get_viewport_rid()
	)

	if gpu_frame_time <= 0.0:
		return
		
	var target_frame_time := 1000 / float(GraphicsSettings.get_setting(GraphicsSettings.SETTING.TARGET_FRAME_RATE))
	
	if gpu_frame_time > target_frame_time * panic_threshold:
		panic_counter += 1
		recovery_counter = 0
	elif gpu_frame_time < target_frame_time * recovery_threshold:
		panic_counter = 0
		recovery_counter += 1
	else:
		panic_counter = 0
		recovery_counter = 0

	if panic_counter >= panic_frames:
		set_scale(scale - scale * step)
		panic_counter = 0
	elif recovery_counter >= recovery_frames:
		set_scale(scale + scale * step)
		recovery_counter = 0

func set_scale(value: float):
	var max_scale: float = GraphicsSettings.get_setting(GraphicsSettings.SETTING.RENDER_SCALE)
	var min_scale: float = max_scale * 0.5;
	var new_scale = clampf(value, min_scale, max_scale)
	if is_equal_approx(new_scale, scale):
		return

	scale = new_scale
	get_viewport().scaling_3d_scale = scale

func on_setting_changed(setting, value) -> void:
	match setting:
		GraphicsSettings.SETTING.DYNAMIC_RENDER_SCALE:
			toggle(is_same(value, GraphicsSettings.DYNAMIC_RENDER_SCALE.ON))
		GraphicsSettings.SETTING.TARGET_FRAME_RATE:
			set_scale(GraphicsSettings.get_setting(GraphicsSettings.SETTING.RENDER_SCALE))

func toggle(value: bool) -> void:
	set_process(value)
	RenderingServer.viewport_set_measure_render_time(
		get_viewport().get_viewport_rid(),
		value
	)
	set_scale(GraphicsSettings.get_setting(GraphicsSettings.SETTING.RENDER_SCALE))
