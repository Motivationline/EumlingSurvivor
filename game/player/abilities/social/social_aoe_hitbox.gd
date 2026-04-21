@tool
class_name SocialAOEHitBox extends HitBox

## How much "hp" does this social aoe "convince" per second
var rate: float = 0:
	set(value):
		rate = value * damage_cooldown
