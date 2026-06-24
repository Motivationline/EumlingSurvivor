class_name GameCamera
extends Camera3D
## The camera used in levels. Configurable with different behaviours.

## Controls how the camera behaves.
@export var behaviour: CameraBehaviour = NormalBehaviour.new()

var player: CharacterBody3D
var offset_x = 0.0
var offset_z = 0.0
var original_size: float = size
var return_to_original_size: bool = false


func _ready() -> void:
	player = Player.player
	player.camera = self
	offset_x = position.x
	offset_z = position.z

	behaviour.setup(self)


func _physics_process(_delta: float) -> void:
	if return_to_original_size:
		size = lerpf(size, original_size, 0.1)
	if size == original_size:
		return_to_original_size = false

	behaviour.update_camera(self)


func switch_to_normal_behaviour() -> void:
	behaviour = NormalBehaviour.new()
	behaviour.setup(self)
	return_to_original_size = true
