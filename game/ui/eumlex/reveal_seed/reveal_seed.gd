@tool
extends Node3D
@onready var seed_animation: AnimationPlayer = $seed_animation

var mini_eumlings: Array[Node]
var eumling: Eumling

func _ready() -> void:
	mini_eumlings = $Mini_Eumling_Anchor.get_children()
	seed_animation.play("RESET")

func setup(_eumling: Eumling, remaining_amount: int = 0):
	eumling = _eumling
	%job_title.text = eumling.name
	%job_image.texture = eumling.image
	if remaining_amount > 0:
		%NumberCircleLabel3D.text = str(remaining_amount)
	else:
		%NumberCircleLabel3D.get_parent().hide()

signal completed

var active_press: bool = false
var progress: int = 0
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event.is_action("ui_accept"):
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

func reveal_emuling():
	seed_animation.play("reveal")
	GlobalMusicManager.request_music(SongList.TRACK.GAMBA,MusicTransition.instant())
	await seed_animation.animation_finished
	progress = 99

	
func _show_eumling(_index: int):
	if mini_eumlings == null: return
	for i in mini_eumlings.size():
		if i == _index:
			mini_eumlings[i].show()
		else:
			mini_eumlings[i].hide()
	
func prepare():
	_show_eumling(eumling.type)
