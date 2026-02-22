@tool
extends SoundEvent
@export var reveal_event: SoundEvent
@export var reset_event: SoundEvent


var progress:int = 0

func start():
	pass


func advance(_name:StringName):
	progress += 1;
	if progress == 5:
		reveal_event.start()


func reset():
	reset_event.start()
	progress = 0
