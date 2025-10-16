extends EventStrategy
## Removes the node when event is called
class_name MarkTargetAsHitTargetsEventStrategy


func event_triggered(_data):
	if len(parent.targets) > 0:
		parent._add_hit(parent.targets[0])
		parent._remove_target(parent.targets[0])
