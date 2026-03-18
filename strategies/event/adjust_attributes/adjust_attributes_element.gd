class_name AdjustAttributesElement extends Resource

## Name of the attribute you want to adjust. 
## Must be the exact value like it's written in code, e.g. [code]global_position[/code] or [code]max_health[/code]. 
@export var attribute: String
## Make sure you select the correct data type
@export var value: Variant
## How to apply the value to the attribute.  
## [b]Only choose "add" or "multiply" for value types where that makes sense![/b] 
@export_enum("add", "set", "multiply") var operation = "set"

func adjust(node: Node):
	if not node.get(attribute):
		push_warning("Attribute " + attribute + " not found on node " + node.name)
		return
		
	match operation:
		"add":
			node.set(attribute, node.get(attribute) + value)
		"set":
			node.set(attribute, value)
		"multiply":
			node.set(attribute, node.get(attribute) * value)
