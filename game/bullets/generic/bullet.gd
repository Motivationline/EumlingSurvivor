extends CharacterBody3D
class_name Bullet

@export var damage: float = 2.0:
	set(new_dmg):
		damage = new_dmg
		if (hit_box): hit_box.damage = new_dmg
@export var speed: Curve
@export var lifetime: float = 2.0
@onready var hit_box: HitBox = $HitBox

var current_lifetime: float = 0


func setup(_owner: Enum.GROUP, pos: Vector3, rot: Vector3):
	if (_owner == Enum.GROUP.PLAYER):
		hit_box.can_hit = Enum.HURTBOX.ENEMY
		hit_box.attached_to = Enum.HITBOX.PLAYER
	elif (_owner == Enum.GROUP.ENEMY):
		hit_box.can_hit = Enum.HURTBOX.PLAYER
		hit_box.attached_to = Enum.HITBOX.ENEMY
	global_position = pos
	global_position.y = 1
	global_rotation = rot
	hit_box.damage = damage

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	await _before_removal()
	queue_free()

func _physics_process(delta: float) -> void:
	current_lifetime += delta
	var current_speed = speed.sample(current_lifetime / lifetime)
	velocity = - transform.basis.z * current_speed * delta

	move_and_collide(velocity)

func _before_removal(): pass
