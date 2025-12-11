extends Resource
class_name Upgrade

@export var type: Enum.UPGRADE
@export var method: Enum.UPGRADE_METHOD
@export var value: float
@export var rarity: Enum.RARITY

func _init(_type: Enum.UPGRADE, _method: Enum.UPGRADE_METHOD, _value: float, _rarity: Enum.RARITY = Enum.RARITY.COMMON) -> void:
	type = _type
	method = _method
	value = _value
	rarity = _rarity

func apply(_value: float) -> float:
	match method:
		Enum.UPGRADE_METHOD.ABSOLUTE:
			return _value + value
		Enum.UPGRADE_METHOD.MULTIPLIER:
			return _value * value
	
	return _value


func _to_string() -> String:
	return "%s, %s, %s" % [Enum.UPGRADE.keys()[type], Enum.UPGRADE_METHOD.keys()[method], value]

# TODO: remove this? or sort first?
static func apply_all(_value: float, all: Array[Upgrade]) -> float:
	for upgrade in all:
		_value = upgrade.apply(_value)
	
	return _value
