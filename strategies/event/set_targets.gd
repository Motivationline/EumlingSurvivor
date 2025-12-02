extends EventStrategy
## Set the targets based based on the target Strategy
class_name SetTargetsEventStrategy

## Add Node pool inside this Array
@export var targeting_strats: Array[ProjectileTargetStrategy]

func event_triggered(_data):
	
	parent.set_targets()
	
	#for n in targeting_strats:
		##set targets
		#n.find_target()
