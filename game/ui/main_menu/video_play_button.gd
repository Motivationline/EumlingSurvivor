extends TextureButton
##Button that plays the intro video

var video:PackedScene

##Video player is attached to this node. Important for layout.
@export var video_parent:Control
var video_instance:VideoStreamPlayer 
func _ready():
	video = load("uid://bhtcrhderikbh")
	pressed.connect(_on_play_button_pressed)


func _on_play_button_pressed() -> void:
	video_instance = video.instantiate()
	video_parent.add_child(video_instance)
	video_instance.z_index = 5
	GlobalMusicManager.request_music(SongList.TRACK.NOTHING,MusicTransition.instant())
	await video_instance.finished
	close_video()

func _input(event):
	if event.is_action_pressed("openPauseMenu") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		close_video()
		


func close_video() -> void:
	if video_instance:
		video_instance.queue_free()
		GlobalMusicManager.request_music(SongList.TRACK.TITLE, MusicTransition.instant())
