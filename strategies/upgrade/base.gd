extends Strategy
class_name UpgradeStrategy

enum METHOD {ABSOLUTE, MULTIPLIER}

@export var type: Enum.UPGRADE
@export var method: METHOD 
@export var value: float

func apply(_value: float) -> float:
	match method:
		METHOD.ABSOLUTE:
			return _value + value
		METHOD.MULTIPLIER:
			return _value * value
	
	return _value
