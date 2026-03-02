extends Ability
@onready var social_aoe: SocialAOE = $Social_AOE

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

	var size: float = 1 + amt_eumlings * 0.75
	social_aoe.adjust_size_shape(size)
	social_aoe.adjust_size_visuals(size)

	var rate: float = 100 + (amt_eumlings - 1) * 50
	social_aoe.hitbox.rate = rate
