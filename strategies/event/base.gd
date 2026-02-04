@abstract
extends Strategy
## Base class for event strategies. [color=red]Do not add, doesn't do anything.[/color]
class_name EventStrategy

func event_triggered(_data):
	if is_active:
		execute_event(_data)
	else:
		pass
		#pech gehabt 🤷‍♂ 😭

@abstract func execute_event(_data)
