extends EventStrategy
## Rotates the parent to face the targets
class_name LookAtTargetEventStrategy

func execute_event(_data):
	if len(parent.targets) > 0:
		var target = parent.targets[0]
		if not parent.position.is_equal_approx(target.position):
			parent.look_at(target.position,Vector3(0,1,0))
