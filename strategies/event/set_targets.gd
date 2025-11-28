extends EventStrategy
## Set the targets based based on the target Strategy
class_name SetTargetsEventStrategy

## Add Node pool inside this Array
@export var targeting_strats: Array[ProjectileTargetStrategy]
## if checked, clears the targets Array before adding new ones
@export var remove_current: bool = false

func event_triggered(_data):
	
	parent.set_targets(remove_current)
