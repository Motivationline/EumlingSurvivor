extends StateMachinePoweredEntity
class_name MiniEumling
@onready var visuals: Node3D = $Visuals

@export var celebration_state: State

func _ready() -> void:
	super()
	get_tree().get_first_node_in_group("Level").level_cleared.connect(celebrate)

func celebrate() -> void:
	if state_machine and celebration_state:
		state_machine.switch_to_state(celebration_state)
