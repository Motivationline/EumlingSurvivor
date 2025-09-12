@tool
extends State
## Picks a random State from all StateMachine Childs, self excluded
class_name PickRandomState

## optional wait Time until the next State starts
@export var wait_time: float = 0.1:
	set(new_value):
		wait_time = max(new_value, 0)

var done: bool = false

func setup(_parent: Enemy, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)
	done = false
	next_state = self

func enter():
	super()
	done = false
	next_state = self
	pick_random_state()

func physics_process(_delta: float) -> State:
	if(done) : return return_next()
	return null

func pick_random_state():
	var states: Array[Node] = get_parent().get_children()
	while next_state is PickRandomState:
		var selector = randi_range(0, len(states)-1)
		next_state = states[selector]
	print(next_state)
	await get_tree().create_timer(wait_time).timeout
	done = true
	
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super ()
	return warnings
