extends Control

const PROGRESS_EMPTY = preload("uid://cjaigtkg6fgd8")
const PROGRESS_ACTIVE = preload("uid://chlu42bsc22aa")
const PROGRESS_COMPLETE = preload("uid://c25hfu5gdb5mo")
const PROGRESS_BOSS = preload("uid://dg4xb1ktpoadp")

func update_visuals(total: int, remaining: int):
	if remaining == 1:
		%ProgressDisplay.hide()
		return
	
	%ProgressDisplay.show()
	var stage_marker = %StageMarker
	Utils.remove_all_children(stage_marker)
	
	for i in total:
		var rect = TextureRect.new()
		
		if i == total - 1:
			rect.texture = PROGRESS_BOSS
		elif i < total - remaining:
			rect.texture = PROGRESS_COMPLETE
		else:
			rect.texture = PROGRESS_EMPTY
		stage_marker.add_child(rect)
	
	var currentMarker = stage_marker.get_child(total - remaining)
	
	await get_tree().process_frame
	if total == remaining:
		%CurrentMarker.global_position = Vector2(-%CurrentMarker.size.x, currentMarker.global_position.y) 
	var tween: Tween = create_tween()
	tween.tween_property(%CurrentMarker, "global_position", currentMarker.global_position, 1)
	
