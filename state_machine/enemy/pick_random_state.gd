@tool
extends State
## Picks a random State from the given States Array
class_name PickRandomState

## optional wait Time until the next State starts
@export var wait_time: float = 0:
	set(new_value):
		wait_time = max(new_value, 0)
		
@export_category("States")
## Add State pool inside this Array
@export var states: Array[State]:
	set(new_value):
		states = new_value
		update_configuration_warnings()

var done: bool = false

func setup(_parent: CharacterBase, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)
	done = false
	next_state = self

func enter():
	super ()
	done = false
	next_state = self
	pick_random_state()

func physics_process(_delta: float) -> State:
	if (done): return return_next()
	return null

func pick_random_state():
	var selector = randi_range(0, len(states) - 1)
	next_state = states[selector]
	await get_tree().create_timer(wait_time).timeout
	done = true

func get_possible_next_states() -> Array[State]:
	return states

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super ()
	# remove parent warning about next state
	var index = warnings.find("Needs a Next State")
	if (index >= 0): warnings.remove_at(index)

	if(states.size() <= 0): warnings.append("Needs at least one state to transition to.")
	return warnings
