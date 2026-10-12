extends CanvasLayer
class_name LoadingScreen

signal loading_screen_ready
signal loading_screen_done

@export var animation_player: AnimationPlayer

func _ready() -> void:
	await animation_player.animation_finished
	loading_screen_ready.emit()

func _on_progress_changed(_new_value: float):
	pass

func _on_load_finished(_scene):
	animation_player.play_backwards("transition")
	await animation_player.animation_finished
	loading_screen_done.emit()
	queue_free()