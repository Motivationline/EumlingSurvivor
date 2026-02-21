@tool
extends Node3D
@onready var seed_animation: AnimationPlayer = $seed_animation

var mini_eumling: Array[Node]
@export_range(0, 5) var which_eumling_is_shown: int

func _ready() -> void:
	mini_eumling = $Mini_Eumling_Anchor.get_children()
	seed_animation.play("RESET")

signal completed

var active_press: bool = false
var progress: int = 0
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed() and not active_press:
			active_press = true
			advance()
		if not event.is_pressed() and active_press:
			active_press = false

func advance():
	if progress >= 4:
		if progress == 99:
			completed.emit()
		return
	progress += 1;
	if progress <= 3:
		seed_animation.play("click_0" + str(progress))
	if progress == 4:
		reveal_emuling()
		MusicPlayer.queue_specific_track(MusicPlayer.LEVEL.GAMBA)

func reveal_emuling():
	seed_animation.play("reveal")
	await seed_animation.animation_finished
	progress = 99

	
func _show_eumling(_index: int):
	if mini_eumling == null: return
	for i in 5:
		if i == _index:
			mini_eumling[i].show()
		else:
			mini_eumling[i].hide()
	
func prepare():
	_show_eumling(which_eumling_is_shown)
