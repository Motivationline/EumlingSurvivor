class_name DecideValueCheck extends Resource

## Minium inclusive (value >= minimum) limit to check.
## Can be omitted to only check for against maximum.
## [b]If both minimum and maximum are omitted, this will always return true.[/b]
@export var minimum: Variant
## Maximum inclusive (value <= maximum) limit to check.
## Can be omitted to only check against minimum.
## [b]If both minimum and maximum are omitted, this will always return true.[/b]
@export var maximum: Variant
## If true, inverts the check. That means that it will check if the value is OUTSIDE of the given range.
@export var inverted: bool

func check(value: Variant) -> bool:
	var result: bool = false
	if minimum == null and maximum == null: result = true
	elif minimum == null:
		result = value <= maximum
	elif maximum == null:
		result = value >= minimum
	else:
		result = value >= minimum and value <= maximum
	
	if inverted:
		result = not result
	return result
