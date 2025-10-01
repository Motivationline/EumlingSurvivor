extends EventStrategy
## Removes the node when event is called
class_name MarkTargetAsHitTargetsEventStrategy


func event_triggered(_data):
	for t in parent.targeting:
		if t.isActive:
			if len(t.targets) > 0:
				parent._add_hit(t.targets[0])
				parent._remove_target(t.targets[0])
