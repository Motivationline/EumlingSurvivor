@tool
extends Level

@export var ready_to_end:bool = false


func _process(_delta: float) -> void:
	super(_delta)
	boss = get_tree().get_first_node_in_group("Enemy")
	
func spawn_cage():
	super()
	is_boss_level = false

func animate_cage():
	var goal_process_mode = goal_area.process_mode
	goal_area.process_mode = Node.PROCESS_MODE_DISABLED
	var tween := caged_eumling.create_tween()
	tween.tween_property(caged_eumling, "global_position", caged_eumling.global_position + Vector3.UP * 2, 2)
	tween.tween_property(caged_eumling, "global_position", goal_area.global_position, 1)
	tween.tween_callback(func():
		goal_area.process_mode = goal_process_mode
	) 

func tracked_enemy_died(_enemy: Node) -> void:
	tracked_enemy_counter -= 1
	if tracked_enemy_counter == 0 and _enemy.is_queued_for_deletion() and state == LEVEL_STATE.PLAYING and ready_to_end:
		if is_boss_level:
			spawn_cage()
			GlobalMusicManager.request_music(SongList.TRACK.NOTHING, MusicTransition.instant(), true, GlobalMusicManager.current_noise)
			GlobalMusicManager.request_incidental(SongList.INCIDENTAL.BOSS_DEFEATED, GlobalMusicManager.BUS_ID.MUSIC, 2)
		else:
			clear_level()
