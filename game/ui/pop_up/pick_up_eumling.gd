extends Control

@export var eumling_text : Dictionary[Enum.EUMLING_TYPE, Label] = {}
@export var skill_text : Dictionary[Enum.EUMLING_TYPE, Label] = {}
@export var eumlings : Dictionary[Enum.EUMLING_TYPE, PackedScene] = {}

signal done

var currently_visible_text: Label


func setup(eumling: Eumling):
	get_tree().paused = true
	var eumling_scene = eumlings.get(eumling.type)
	if eumling_scene:
		var instance = eumling_scene.instantiate()
		%MiniEumlingMarker.add_child(instance)
		var anim_tree = Utils.find_first_animation_tree(instance)
		if anim_tree:
			anim_tree.set("parameters/Transition/transition_request", "celebrate")
	%CollectEumlexPage.find_child("EumlexInfoPage").set_info(eumling)

func next():
	%ContinueButton.hide()
	%PageAnimationPlayer.play("to_eumlex")
	await %PageAnimationPlayer.animation_finished
	completed()

func completed():
	get_tree().paused = false
	done.emit()
	queue_free()
