extends EventStrategy
## Removes the Nodes inside the given Array
class_name DestroyNodeEventStrategy

## Add Node pool inside this Array
@export var nodes_to_destroy: Array[Node]

## trigger the action after a given delay
@export var is_delayed: bool = false
## after delay time has passed, the action is triggered
@export var delay: float = 0

var has_hit: bool = false

func event_triggered(_data):
	if is_delayed:
		await get_tree().create_timer(delay).timeout
		
	#TODO: make this piercing dependant?
	if not has_hit:
		for n in nodes_to_destroy:
			n.queue_free()
		has_hit = true
