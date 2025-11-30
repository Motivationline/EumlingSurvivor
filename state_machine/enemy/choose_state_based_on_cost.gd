@tool
extends State

## Chooses a next state based on the cost of that state, taking the parents current resources into account
class_name ChooseStateBasedOnCost

## The state to fall back to if all else doesn't get chosen
@export var fallback: State:
	set(value):
		fallback = value
		update_configuration_warnings()

## "Random" selects a random state that matches the requirement.\n
## "First" selects the first state that matches the cost requirement.\n
## "Last" selects the last state that matches the cost requirement.\n
## "Highest" selectes the state with the highest cost that's affordable
## "Lowest" selects the state with the lowest cost that's affordable
@export_enum("RANDOM", "FIRST", "LAST", "HIGHEST", "LOWEST") var selection = "FIRST"

## The states from which to choose the next one
@export var states: Array[State]

var done: bool = false

func setup(_parent: CharacterBase, _animation: AnimationTree) -> void:
	super (_parent, _animation)
	next_state = fallback

func enter() -> void:
	super ()
	done = false
	choose_next_state()


func choose_next_state():
	var available_resources = parent.resource
	var possible_states = states.filter(func(state): return state.resource_cost <= available_resources)

	if possible_states.is_empty():
		next_state = fallback
		done = true
		return
	
	match selection:
		"FIRST":
			next_state = possible_states.front()
		"LAST":
			next_state = possible_states.back()
		"RANDOM":
			next_state = possible_states.pick_random()
		"HIGHEST":
			possible_states.sort_custom(func(a, b): return a.resource_cost > b.resource_cost)
			next_state = possible_states.front()
		"LOWEST":
			possible_states.sort_custom(func(a, b): return a.resource_cost > b.resource_cost)
			next_state = possible_states.back()

	done = true


func physics_process(_delta: float) -> State:
	if (done): return return_next()
	return null

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not fallback:
		warnings.append("You need to set a fallback state.")
	return warnings
