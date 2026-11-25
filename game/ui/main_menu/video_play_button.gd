extends TextureButton
##Button that plays the intro video

var video: PackedScene

##Video player is attached to this node. Important for layout.
@export var video_parent: Control
var video_instance: VideoStreamPlayer
func _ready():
	video = load("uid://bhtcrhderikbh")
	pressed.connect(_on_play_button_pressed)
	


func _on_play_button_pressed() -> void:
	if !video_instance:
		video_instance = video.instantiate()
		video_instance.gui_input.connect(on_video_gui_input)
		video_parent.add_child(video_instance)
		video_instance.grab_focus()
		get_tree().paused = true
		
		video_instance.z_index = 5
		
		GlobalMusicManager.request_music(SongList.TRACK.NOTHING, MusicTransition.instant())
		
		video_instance.finished.connect(close_video)
		

func on_video_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		close_video()

func _unhandled_input(event):
	if event.is_action_pressed("close_menu") and video_instance:
		close_video()
#
#func _process(_delta):
	#if Input.is_action_just_pressed("close_menu"):
		#close_video()
		#print("b")
	#print("a")

func close_video() -> void:
	get_tree().paused = false
	if video_instance:
		video_instance.queue_free()
		GlobalMusicManager.request_music(SongList.TRACK.TITLE, MusicTransition.instant())
