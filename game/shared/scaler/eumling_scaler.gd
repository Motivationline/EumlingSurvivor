## Adjusts values of the attached node based on the amount of active mini eumlings of the chosen type 
class_name EumlingScaler extends Resource

## Which types to count for
@export var types: Array[Enum.EUMLING_TYPE] = []

@export var zero: Array[AdjustAttributesElement] = []
@export var one: Array[AdjustAttributesElement] = []
@export var two: Array[AdjustAttributesElement] = []
@export var three: Array[AdjustAttributesElement] = []

func _update_amount(eumlings: Array[Enum.EUMLING_TYPE], node: Node):
	var count: int = 0
	for type in types:
		count += eumlings.count(type)
	
	apply(count, node)

func apply(amount: int, node: Node):
	var override : Array[AdjustAttributesElement] 
	match amount:
		0:
			override = zero
		1:
			override = one
		2:
			override = two
		3:
			override = three
	for element in override:
		if element:
			element.adjust(node)

func setup_and_apply(attached_node: Node) -> void:
	if attached_node.is_in_group("ShaderPrecompiler"):
		return
	
	if not Data.active_eumlings_changed.is_connected(_update_amount):
		Data.active_eumlings_changed.connect(_update_amount.bind(attached_node))

	var mini_eumlings = Data.game_data.active_mini_eumlings

	_update_amount(mini_eumlings, attached_node)
