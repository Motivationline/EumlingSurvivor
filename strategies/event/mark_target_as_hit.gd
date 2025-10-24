extends EventStrategy
## Removes the node when event is called
class_name MarkTargetAsHitTargetsEventStrategy


func event_triggered(_data):
	if len(parent.targets) > 0:
		var hit = arrays_overlap(parent.targets, parent.hit_box.overlapping)
		if hit:
			var i = parent.targets.find(hit)
			parent._add_hit(hit)
			parent._remove_target(parent.targets[i])

func arrays_overlap(arr1, arr2):
	var arr2_dict = {}
	for node in arr2:
		arr2_dict[node] = true
	for node in arr1:
		if arr2_dict.has(node):
			return node
	return false
