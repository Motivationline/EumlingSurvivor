@abstract
extends Strategy
## Base class for event strategies. [color=red]Do not add, doesn't do anything.[/color]
class_name EventStrategy

signal event_happened

func event_triggered(_data):
	if is_active:
		execute_event(_data)
		event_happened.emit()
	else:
		pass
		#pech gehabt 🤷‍♂ 😭

@abstract func execute_event(_data)
