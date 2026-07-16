@tool
## Allows you to trigger the completed condition externally, probably through a signal
class_name SignalInterruptCondition extends InterruptCondition

var triggered: bool = false

func start():
	triggered = false

func evaluate() -> bool:
	return triggered

func trigger_interrupt():
	triggered = true
