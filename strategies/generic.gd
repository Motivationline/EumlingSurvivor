extends Resource
class_name Strategy

var node: Node

## Adds all functionality that needs to be set up for this strategy to function properly
func _setup(_attached_to: Node) -> void:
    node = _attached_to