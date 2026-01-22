@tool
extends EventStrategy
## Triggers a State from the State Machine
class_name PlayAnimationEventStrategy

## Set up trigger(s) for your animation transition here and it will get triggered when this state starts.
## use the full path for the name, e.g. "parameters/conditions/attack" and make sure to use the correct type!
@export var animation_trigger: Dictionary[String, Variant]


func event_triggered(_data):
	if parent.animation_tree && animation_trigger.size() > 0:
		for key in animation_trigger.keys():
			parent.animation_tree.set(key, animation_trigger.get(key))
