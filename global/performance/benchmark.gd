extends Node

@export
var sub_viewport: SubViewport

var max_frames := 60
var max_duration := 3.0
var max_samples := 10

var samples: Array[float]

var measured_frames := 0
var elapsed_time := 0.0

var average_frame_time := 0.0

func run():
	sub_viewport.size = get_viewport().get_visible_rect().size
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# extend splash screen to true full screen
	var stretch_mode = get_tree().root.content_scale_aspect
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	
	RenderingServer.viewport_set_measure_render_time(sub_viewport.get_viewport_rid(), true)
	
	measured_frames = 0
	elapsed_time = 0.0
	samples = []
	samples.resize(max_samples)

	while measured_frames < max_frames and elapsed_time < max_duration:
		await RenderingServer.frame_post_draw
		
		measured_frames += 1
		elapsed_time += get_process_delta_time()
		samples[measured_frames % max_samples] = RenderingServer.viewport_get_measured_render_time_gpu(sub_viewport.get_viewport_rid())

	RenderingServer.viewport_set_measure_render_time(sub_viewport.get_viewport_rid(), false)

	for sample in samples:
		average_frame_time += sample
		
	average_frame_time = average_frame_time / min(measured_frames, max_samples)
	
	# restore aspect ratio
	get_tree().root.content_scale_aspect = stretch_mode
