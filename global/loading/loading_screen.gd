extends CanvasLayer
class_name LoadingScreen

@export var loading_texts: Array[String] = []
@export var loading_label: Label
@export var mini_eumling_sprite_frames: Dictionary[Enum.EUMLING_TYPE, SpriteFrames]
@export var eumling_sprite: AnimatedSprite2D
@export var mini_sprites: Array[AnimatedSprite2D]

signal loading_screen_ready
signal loading_screen_done

@export var animation_player: AnimationPlayer

func _ready() -> void:
	setup_visuals()
	await animation_player.animation_finished
	loading_screen_ready.emit()

func _on_progress_changed(_new_value: float):
	pass

func _on_load_finished(_scene):
	animation_player.play_backwards("transition")
	await animation_player.animation_finished
	loading_screen_done.emit()
	queue_free()

func setup_visuals() -> void:
	loading_label.text = loading_texts.pick_random()
	var mini_eumlings = Data.game_data.active_mini_eumlings

	for s in mini_sprites:
		s.hide()

	for i in mini_eumlings.size():
		var frames = mini_eumling_sprite_frames.get(mini_eumlings[i])
		if not frames: continue
		var sprite = mini_sprites[i]
		sprite.sprite_frames = frames
		sprite.show()
		sprite.play()
