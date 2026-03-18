class_name DifficultyScaler extends Resource

@export var introduction: Array[AdjustAttributesElement]
@export var easy: Array[AdjustAttributesElement]
@export var medium: Array[AdjustAttributesElement]
@export var hard: Array[AdjustAttributesElement]

func apply(difficulty: int, node: Node):
	var override : Array[AdjustAttributesElement] 
	match difficulty:
		0:
			override = introduction
		1:
			override = easy
		2:
			override = medium
		3:
			override = hard
	if not override: return
	for element in override:
		if element:
			element.adjust(node)
