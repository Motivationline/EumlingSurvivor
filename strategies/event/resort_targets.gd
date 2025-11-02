extends EventStrategy
## Resorts the targets by distance
class_name ResortTargetsTargetsEventStrategy


func event_triggered(_data):
	_sort_targets_by_distance(parent.targets)
	
func _sort_targets_by_distance(targets):
	targets.sort_custom(_sort_by_distance)
	
func _sort_by_distance(a: Node, b: Node) -> bool:
	var dist_a = parent.global_transform.origin.distance_to(a.global_transform.origin)
	var dist_b = parent.global_transform.origin.distance_to(b.global_transform.origin)
	return dist_a < dist_b
