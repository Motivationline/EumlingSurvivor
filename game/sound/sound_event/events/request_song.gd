class_name SongRequester extends SoundEvent

@export var track:MusicPlayer.TRACK
@export var transition:MusicPlayer.TRANSITIONS
@export var crossfade_duration:float = 0
@export var backround_noise:bool = false


func start() -> void:
	if !GlobalAudioManager.music_playing:
		transition = MusicPlayer.TRANSITIONS.INSTANT
	GlobalAudioManager.request_music(track, transition, crossfade_duration, backround_noise)
