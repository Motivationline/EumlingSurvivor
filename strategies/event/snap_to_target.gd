extends EventStrategy
## Removes the node when event is called
class_name SnapToTargetEventStrategy

func event_triggered(_data):
	if len(parent.targets) > 0:
		var target = parent.targets[0]
		parent.look_at(target.position,Vector3(0,1,0))
