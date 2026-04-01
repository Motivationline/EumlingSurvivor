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

func setup_and_apply(attached_node: Node, possible_level: Node):
	if attached_node.is_in_group("ShaderPrecompiler"):
		return
	var difficulty : int= 0
	if possible_level and "difficulty" in possible_level:
		difficulty = possible_level.difficulty
	elif attached_node.is_inside_tree():
		var level = attached_node.get_tree().get_first_node_in_group("Level")
		if level:
			difficulty = level.difficulty

	apply(difficulty, attached_node)
