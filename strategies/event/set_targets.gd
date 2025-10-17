extends EventStrategy
## Removes the node when event is called
class_name SetTargetsEventStrategy

## Add Node pool inside this Array
@export var targeting_strats: ProjectileTargetStrategy:
	set(new_value):
		targeting_strats = new_value

func event_triggered(_data):
	
	parent._set_targets()
	
	#for n in targeting_strats:
	#	#set targets
	#	n.find_targets()
