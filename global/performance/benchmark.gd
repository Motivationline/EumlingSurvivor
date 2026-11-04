extends SubViewport

var max_frames := 60
var max_duration := 3.0

var measured_frames := 0
var elapsed_time := 0.0
var total_gpu_time := 0.0
var average_frame_time := 0.0

func run():
	size = get_tree().root.size
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	RenderingServer.viewport_set_measure_render_time(get_viewport_rid(), true)
	
	for i in range(10): #warm up
		await RenderingServer.frame_post_draw

	measured_frames = 0
	elapsed_time = 0.0
	total_gpu_time = 0.0

	while measured_frames < max_frames and elapsed_time < max_duration:
		await RenderingServer.frame_post_draw
		measured_frames += 1
		elapsed_time += get_process_delta_time()
		total_gpu_time += RenderingServer.viewport_get_measured_render_time_gpu(get_viewport_rid())

	RenderingServer.viewport_set_measure_render_time(get_viewport_rid(), false)
	average_frame_time = total_gpu_time / measured_frames
