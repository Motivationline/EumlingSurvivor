@tool
extends State
## Let The Entity Die
class_name KillSelfState

var done: bool = false

func setup(_parent: Enemy, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)
	done = false

func enter():
	super()
	done = false
	kill()

func physics_process(_delta: float) -> State:
	if(done) : return return_next()
	return null

func kill():
	#play animation before deletion
	# set health to 0 and not just call queue_free for better control over events and such
	parent.health = 0
	done = true
	
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super ()
	return warnings
