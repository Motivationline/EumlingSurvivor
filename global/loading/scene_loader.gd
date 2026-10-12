extends Node

signal ready_to_load
signal progress_changed(progress: float)
signal load_finished(scene: PackedScene)

var loading_screen: PackedScene = preload("uid://d2kq1cxqiwbkm")
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)


func load_scene(_scene_path: String) -> void:
	scene_path = _scene_path

	var new_load_screen = loading_screen.instantiate();
	add_child(new_load_screen)

	progress_changed.connect(new_load_screen._on_progress_changed)
	load_finished.connect(new_load_screen._on_load_finished)

	await new_load_screen.loading_screen_ready
	ready_to_load.emit()

	start_load()


func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true);
	

func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			# get_tree().change_scene_to_packed(loaded_resource)
			load_finished.emit(loaded_resource)
