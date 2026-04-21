class_name MoveQuest extends Quest

@export var move_distance_required: float = 8

var total_distance_moved: float = 0
var previous_position: Vector3

func process():
	if done: return
	total_distance_moved += previous_position.distance_to(global_position)
	progress.emit(total_distance_moved, move_distance_required) 
	previous_position = global_position
	if total_distance_moved > move_distance_required:
		complete()

func start():
	previous_position = global_position
	total_distance_moved = 0
	done = false
	progress.emit(total_distance_moved, move_distance_required)

func precondition_is_met() -> bool:
	return true


func complete():
	super()
	Player.player.add_upgrade(Upgrade.new(Enum.UPGRADE.MOVEMENT_SPEED, Enum.UPGRADE_METHOD.ABSOLUTE, 1), true)