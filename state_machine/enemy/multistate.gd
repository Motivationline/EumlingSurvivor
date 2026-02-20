@tool
extends State
## A state that allows you to play multiple states_to_execute at the same time. Has some settings as to when to continue etc.
class_name MultistateState

@export var states_to_execute: Array[State]:
	set(new_value):
		states_to_execute = new_value
		update_configuration_warnings()
@export var states_that_need_to_finish: Array[State]:
	set(new_value):
		states_that_need_to_finish = new_value
		update_configuration_warnings()
@export_enum("any", "all") var which_states_need_to_finish = "all"

var active_states: Array[State]

func setup(_parent: StateMachinePoweredEntity, _animation: AnimationTree):
	super (_parent, _animation)
	for state in states_to_execute:
		state.setup(_parent, _animation)

func enter() -> void:
	for state in states_to_execute:
		state.enter()

	active_states.append_array(states_to_execute)

func process(_delta: float) -> State:
	for state in active_states:
		var result = state.process(_delta)
		if (result != null): # TODO: add this part to a function because it's the same as in physics_process.
			if (result == state):
				state.exit()
				state.enter()
			else:
				active_states.remove_at(active_states.find(state))
				state.exit()

	return check_end()

func physics_process(_delta: float) -> State:
	for state in active_states:
		var result = state.physics_process(_delta)
		if (result != null):
			if (result == state):
				state.exit()
				state.enter()
			else:
				active_states.remove_at(active_states.find(state))
				state.exit()
			
	return check_end()

func exit():
	for state in active_states:
		state.exit()

func check_end() -> State:
	match which_states_need_to_finish:
		"all":
			if (!states_that_need_to_finish.all(is_state_in_active_states)):
				print("I'm done")
				return return_next()
		"any":
			if (states_that_need_to_finish.any(is_state_not_in_active_states)):
				print("I'm done")
				return return_next()
	return null

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super ()
	if (states_that_need_to_finish.size() <= 0): warnings.insert(0, "Need at least 1 state in the list of 'States to execute' that need to finish, otherwise the state will end immediately.")
	if (states_to_execute.size() <= 0): warnings.insert(0, "Need at least 1 state in the list of 'States to execute' that need to be executed, otherwise the state has no effect.")
	if (states_that_need_to_finish.any(is_state_not_in_states_to_execute)): warnings.insert(0, "States that are in 'States that need to finish' but are not inside 'States to execute' as well are considered done.")
	return warnings

func is_state_not_in_states_to_execute(state: State):
	return !states_to_execute.has(state)
func is_state_in_active_states(state: State):
	return active_states.has(state)
func is_state_not_in_active_states(state: State):
	return !active_states.has(state)

func get_possible_next_states() -> Array[State]:
	var states = super()
	states.append_array(states_to_execute)
	return states
