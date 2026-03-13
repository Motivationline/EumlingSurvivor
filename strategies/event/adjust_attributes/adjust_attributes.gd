## [color=red]This Strategy can be dangerous and behave unexpectedly.[/color]
## Let a dev know if something doesn't work the way you want it to.
class_name AdjustAttributesEventStrategy extends EventStrategy

@export var changes: Array[AdjustAttributesElement]

func execute_event(_data):
	for change in changes:
		if not change: continue
		if not parent.get(change.attribute): continue
		
		match change.operation:
			"add":
				parent.set(change.attribute, parent.get(change.attribute) + change.value)
			"set":
				parent.set(change.attribute, change.value)
			"multiply":
				parent.set(change.attribute, parent.get(change.attribute) * change.value)
