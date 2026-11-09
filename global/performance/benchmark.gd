extends SubViewport

var max_frames := 60
var max_duration := 3.0
var max_samples := 10

var samples: Array[float]

var measured_frames := 0
var elapsed_time := 0.0

var average_frame_time := 0.0

func run():
	size = get_tree().root.size
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	RenderingServer.viewport_set_measure_render_time(get_viewport_rid(), true)
	
	measured_frames = 0
	elapsed_time = 0.0
	samples = []
	samples.resize(max_samples)

	while measured_frames < max_frames and elapsed_time < max_duration:
		await RenderingServer.frame_post_draw
		
		measured_frames += 1
		elapsed_time += get_process_delta_time()
		samples[measured_frames % max_samples] = RenderingServer.viewport_get_measured_render_time_gpu(get_viewport_rid())
		print(RenderingServer.viewport_get_measured_render_time_gpu(get_viewport_rid()))

	RenderingServer.viewport_set_measure_render_time(get_viewport_rid(), false)

	for sample in samples:
		average_frame_time += sample
		
	average_frame_time = average_frame_time / min(measured_frames, max_samples)
