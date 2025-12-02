extends EventStrategy
## Rotates the parent to face the targets
class_name LookAtTargetEventStrategy

func event_triggered(_data):
	if len(parent.targets) > 0:
		var target = parent.targets[0]
		parent.look_at(target.position,Vector3(0,1,0))
