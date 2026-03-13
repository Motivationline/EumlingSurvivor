@tool
class_name TriggerEventState extends State

@export var events: Array[EventStrategy]

func setup(_parent: StateMachinePoweredEntity, _animation: AnimationTree) -> void:
	super(_parent, _animation)
	Strategy._setup_array(events, _parent, _parent)

func enter() -> void:
	super()
	for ev in events:
		if ev.is_active:
			ev.event_triggered(null)

func _process(_delta: float) -> void:
	return return_next()