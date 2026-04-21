extends Ability
@onready var social_aoe: SocialAOE = $Social_AOE

## size of the aoe for the first eumling
@export var aoe_size_base: float = 1.0
## additional size of the aoe for every eumling after the first
@export var aoe_size_additional: float = 0.75
## how much HP to convince per second for the first eumling
@export var convince_rate_base: float = 100
## how much HP to convince per second for every eumling after the first
@export var convince_rate_additional: float = 50

func _ready() -> void:
	_type = Enum.EUMLING_TYPE.SOCIAL
	super()

func _process(_delta: float) -> void:
	pass

func _update():
	if amt_eumlings == 0:
		# disable
		social_aoe.hide()
		social_aoe.process_mode = Node.PROCESS_MODE_DISABLED
		return
	social_aoe.show()
	social_aoe.process_mode = Node.PROCESS_MODE_INHERIT

	var size: float = aoe_size_base + (amt_eumlings - 1) * aoe_size_additional
	social_aoe.adjust_size_shape(size)
	social_aoe.adjust_size_visuals(size)

	var rate: float = convince_rate_base + (amt_eumlings - 1) * convince_rate_additional
	social_aoe.hitbox.rate = rate
