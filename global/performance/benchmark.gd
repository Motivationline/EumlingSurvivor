extends SubViewport

signal benchmark_finished(average_frame_time: float)

var warmup_frames := 20
var frames := 80
var frame_counter := 0
var total_frame_time := 0.0

func _ready() -> void:
	size = get_tree().root.size
	render_target_update_mode = SubViewport.UPDATE_ALWAYS

	RenderingServer.viewport_set_measure_render_time(
		get_viewport_rid(), true
	)

func _process(_delta: float) -> void:
	frame_counter += 1

	if frame_counter < warmup_frames:
		return
		
	total_frame_time += RenderingServer.viewport_get_measured_render_time_gpu(
		get_viewport_rid()
	)

	if frame_counter >= frames:
		evaluate()
		set_process(false)

func evaluate() -> void:
	RenderingServer.viewport_set_measure_render_time(
		get_viewport_rid(), false
	)

	benchmark_finished.emit(total_frame_time / frames)
