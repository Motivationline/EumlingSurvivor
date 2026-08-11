@tool
## A SubViewport that updates only when requested.
## Always updates in the editor for previewing.
class_name OffscreenViewport extends SubViewport

func _init() -> void:
	if Engine.is_editor_hint():
		render_target_update_mode = SubViewport.UPDATE_ALWAYS
	else:
		render_target_update_mode = SubViewport.UPDATE_ONCE

func update() -> void:
	render_target_update_mode = SubViewport.UPDATE_ONCE
