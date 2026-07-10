extends Control

@export var eumling_text : Dictionary[Enum.EUMLING_TYPE, Label] = {}
@export var skill_text : Dictionary[Enum.EUMLING_TYPE, Label] = {}
@export var eumlings : Dictionary[Enum.EUMLING_TYPE, PackedScene] = {}

signal done

var progress: int = 0
var eumling: Enum.EUMLING_TYPE
var currently_visible_text: Label

func _input(event: InputEvent) -> void:
	if event.is_pressed() and (event is InputEventScreenTouch or event.is_action_pressed("ui_accept")):
		if progress == 1:
			next()
		elif progress == 3:
			completed()


func setup(type: Enum.EUMLING_TYPE):
	eumling = type
	get_tree().paused = true
	var text = eumling_text.get(type)
	if (text):
		currently_visible_text = text
		text.show()
	var eumling_scene = eumlings.get(type)
	if eumling_scene:
		var instance = eumling_scene.instantiate()
		%MiniEumlingMarker.add_child(instance)
		var anim_tree = Utils.find_first_animation_tree(instance)
		if anim_tree:
			anim_tree.set("parameters/Transition/transition_request", "celebrate")
	await get_tree().create_timer(1).timeout
	progress = 1

func next():
	progress = 2
	currently_visible_text.hide()
	var text = skill_text.get(eumling)
	if (text):
		text.show()
	await get_tree().create_timer(1).timeout
	progress = 3

func completed():
	get_tree().paused = false
	done.emit()
	queue_free()
