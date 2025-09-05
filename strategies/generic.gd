extends Resource
class_name Strategy

var node: Node

static func setupArray(arr: Array, _attached_to: Node):
	var clones: Array[Strategy] = []
	for s in arr:
		if(s && s is Strategy): clones.append(Strategy.setupOne(s, _attached_to))
	return clones

static func setupOne(s: Strategy, _attached_to: Node) -> Strategy:
	s.resource_local_to_scene = true
	var clone = s.copy();
	clone._setup(_attached_to)
	return clone

func copy() -> Strategy:
	return duplicate(true)

## Adds all functionality that needs to be set up for this strategy to function properly
func _setup(_attached_to: Node) -> void:
	node = _attached_to
