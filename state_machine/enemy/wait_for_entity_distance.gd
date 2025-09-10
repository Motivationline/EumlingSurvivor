@tool
extends State

## Detects an entity of a configurable group in a set radius. 
##
## Ends when the Entity is in the desired distance.
class_name WaitForEntityToBeAtDistanceState

## How far does the entity need to be at least before it's [b]considered detected[/b]?
@export var min_distance: float = 0:
	set(new_value):
		min_distance = new_value
		update_configuration_warnings()
## How far does the entity need to be before it's [b]considered not detected[/b]?
@export var max_distance: float = 0:
	set(new_value):
		max_distance = new_value
		update_configuration_warnings()

## Which group of entities to check for. Can be either "Enemy" or "Player"
@export_enum("Enemy", "Player") var group: String:
	set(new_value):
		group = new_value
		update_configuration_warnings()

var min_squared: float
var max_squared: float

func _ready() -> void:
	min_squared = min_distance * min_distance
	max_squared = max_distance * max_distance

func physics_process(_delta: float) -> State:
	var nodes = get_tree().get_nodes_in_group(group)
	for node in nodes:
		if (node == parent): continue
		if (node is Node3D):
			var distance = node.global_position.distance_squared_to(parent.global_position)
			if (distance >= min_squared && distance <= max_squared):
				return return_next()
	
	return null

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = super()
	if (min_distance == max_distance): warnings.append("Min and Max being equal means they will likely never trigger.")
	if (min_distance > max_distance): warnings.append("Min has to be smaller than Max.")
	if (!group): warnings.append("Group is unset.")
	return warnings
