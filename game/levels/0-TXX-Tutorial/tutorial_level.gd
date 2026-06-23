@tool
extends Level

func spawn_cage():
	super()
	caged_eumling.global_position = goal_area.global_position
	is_boss_level = false