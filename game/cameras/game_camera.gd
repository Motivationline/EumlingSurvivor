class_name GameCamera
extends Camera3D
## The camera used in levels. Configurable with different behaviours.

## Controls how the camera behaves.
@export var behaviour: CameraBehaviour = NormalBehaviour.new()

var player: CharacterBody3D
var offset_x = 0.0
var offset_z = 0.0


func _ready() -> void:
	player = Player.player
	player.camera = self
	offset_x = position.x
	offset_z = position.z

	behaviour.setup(self)


func _physics_process(_delta: float) -> void:
	behaviour.update_camera(self)


func switch_to_normal_behaviour() -> void:
	behaviour = NormalBehaviour.new()
	behaviour.setup(self)
