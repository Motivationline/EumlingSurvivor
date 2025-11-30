extends CharacterBase
class_name MiniEumling

@export var state_machine: StateMachine
@export var node_with_animation_tree: Node3D
# States:
#	Idle
#	Follow Player

## How fast this entity moves when it moves
@export_range(0, 100, 0.1) var speed: float = 1

var resource: float = 0.0


func _ready() -> void:
	print("setup state Machine")
	if (state_machine): 
		state_machine.setup(self, find_first_animation_tree(node_with_animation_tree if (node_with_animation_tree) else self))
		state_machine.consumed_resource.connect(consume_resource)

func _process(delta: float) -> void:
	if (state_machine): state_machine.process(delta)

func _physics_process(delta: float) -> void:
	if (state_machine): state_machine.physics_process(delta)

func find_first_animation_tree(node: Node3D) -> AnimationTree:
	if (!node): return null
	for child in node.get_children():
		if (child is AnimationTree): return child
		if (child.get_child_count() > 0 && child is Node3D):
			var tree = find_first_animation_tree(child)
			if (tree && tree is AnimationTree): return tree
	return null
	
func consume_resource(amount: float):
	resource -= amount
