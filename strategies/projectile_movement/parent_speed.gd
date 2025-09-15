extends ProjectileMovementStrategy
## Saves the parents speed at the time of creation and applies it every physics frame
class_name AddParentsVelocityAtTimeOfSpawnProjectileMovementStrategy

var initial_velocity: Vector3 = Vector3.ZERO

func _setup(_parent: Node, _owner: Node):
    super(_parent, _owner)
    if (_owner is CharacterBody3D):
        initial_velocity = _owner.velocity

func apply_movement(_delta: float, _current_lifetime: float, _total_lifetime: float):
    parent.velocity += initial_velocity