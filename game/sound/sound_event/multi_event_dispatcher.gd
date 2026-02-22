@tool
extends SoundEvent
@export var events: Array[SoundEvent]

func start():
	for event in events:
		event.start()
# Called when the node enters the scene tree for the first time.
