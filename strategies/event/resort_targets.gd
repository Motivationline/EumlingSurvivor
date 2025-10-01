extends EventStrategy
## Removes the node when event is called
class_name ResortTargetsTargetsEventStrategy


func event_triggered(_data):
		for t in parent.targeting:
			if t.isActive:
				_sort_targets_by_distance(t.targets)
	
func _sort_targets_by_distance(targets):
	targets.sort_custom(self, "_sort_by_distance")
	
func _sort_by_distance(a: Node, b: Node) -> bool:
	var dist_a = parent.global_transform.origin.distance_to(a.global_transform.origin)
	var dist_b = parent.global_transform.origin.distance_to(b.global_transform.origin)
	return dist_a < dist_b