## Adjusts values of the attached node based on the amount of active mini eumlings of the chosen type 
class_name EumlingScaler extends Resource

## Which types to sort for
@export var types: Array[Enum.EUMLING_TYPE] = []

@export var zero: Array[AdjustAttributesElement]
@export var one: Array[AdjustAttributesElement]
@export var two: Array[AdjustAttributesElement]
@export var three: Array[AdjustAttributesElement]

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
	
	var mini_eumlings = Data._active_mini_eumlings

	var count: int = 0
	for type in types:
		count += mini_eumlings.count(type)
	
	apply(count, attached_node)