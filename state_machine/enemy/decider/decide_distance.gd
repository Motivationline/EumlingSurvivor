@tool
extends DeciderState

## Chooses a State based on the distance of this node to another node
class_name DecideDistanceState

@export_range(0, 100) var distance_to_check: float = 0.0
@export_enum("Enemy", "Player") var target_group: String = "Player":
	set(value):
		target_group = value
		update_configuration_warnings()
@export var state_if_distance_is_smaller: State:
	set(value):
		state_if_distance_is_smaller = value
		update_configuration_warnings()
@export var state_if_distance_is_larger: State:
	set(value):
		state_if_distance_is_larger = value
		update_configuration_warnings()
@export var state_if_no_node_found: State:
	set(value):
		state_if_no_node_found = value
		update_configuration_warnings()

var done: bool = false

func setup(_parent: StateMachinePoweredEntity, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)
	done = false
	next_state = self

func enter() -> void:
	super()
	var nodes: Array[Node] = parent.get_tree().get_nodes_in_group(target_group)
	var min_distance: float = INF
	var found_node: Node3D
	for node in nodes:
		if node == parent: continue
		if node is Node3D:
			var distance = node.global_position.distance_squared_to(parent.global_position)
			if distance < min_distance:
				min_distance = distance
				found_node = node
	
	if not found_node:
		next_state = state_if_no_node_found
	
	elif min_distance < distance_to_check * distance_to_check:
		next_state = state_if_distance_is_smaller
	else:
		next_state = state_if_distance_is_larger
	done = true

func physics_process(_delta: float) -> State:
	if (done): return return_next()
	return null

func get_possible_next_states() -> Array[State]:
	return [state_if_distance_is_larger, state_if_distance_is_smaller, state_if_no_node_found]

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if not target_group:
		warnings.append("You need to choose a target group.")

	if not state_if_distance_is_larger or not state_if_distance_is_smaller or not state_if_no_node_found:
		warnings.append("You need to define states for all three options.")


	return warnings
