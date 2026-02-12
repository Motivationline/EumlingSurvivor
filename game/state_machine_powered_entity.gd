extends CharacterBody3D
class_name StateMachinePoweredEntity

@export_category("Behavior")
@export var node_with_animation_tree: Node3D
@export var state_machine: StateMachine


var resource: float = 0.0

func _ready() -> void:
	if (state_machine): 
		state_machine.setup(self, Utils.find_first_animation_tree(node_with_animation_tree if (node_with_animation_tree) else self))
		state_machine.consumed_resource.connect(consume_resource)

func consume_resource(amount: float):
	resource -= amount

func _process(delta: float) -> void:
	if (state_machine): state_machine.process(delta)

func _physics_process(delta: float) -> void:
	if (state_machine): state_machine.physics_process(delta)
