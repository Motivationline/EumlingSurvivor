@tool
@icon("wind_icon.svg")
class_name WorldWind extends Node3D

const WIND_NOISE_UNIFORM: StringName = &"wind_noise"
const WIND_NOISE_SCALE_UNIFORM: StringName = &"wind_noise_scale"
const WIND_SPEED_UNIFORM: StringName = &"wind_speed"
const WIND_STRENGTH_UNIFORM: StringName = &"wind_strength"
const WIND_DIRECTION_UNIFORM: StringName = &"wind_direction"

@export var wind_noise: Texture2D:
	set(value):
		wind_noise = value
		if wind_noise != null:
			RenderingServer.global_shader_parameter_set_override(WIND_NOISE_UNIFORM, wind_noise.get_rid())
		else:
			RenderingServer.global_shader_parameter_set_override(WIND_NOISE_UNIFORM, null)

@export var wind_noise_scale: float = 20.0:
	set(value):
		wind_noise_scale = value
		RenderingServer.global_shader_parameter_set_override(WIND_NOISE_SCALE_UNIFORM, wind_noise_scale)

@export_range(0.0, 3.0, 0.001) var wind_speed: float = 0.2:
	set(value):
		wind_speed = value
		RenderingServer.global_shader_parameter_set_override(WIND_SPEED_UNIFORM, wind_speed)

@export_range(0.0, 1.0, 0.001) var wind_strength: float = 0.2:
	set(value):
		wind_strength = value
		RenderingServer.global_shader_parameter_set_override(WIND_STRENGTH_UNIFORM, wind_strength)

func _ready() -> void:
	set_notify_transform(true)
	wind_noise = wind_noise # trigger setter to update shader uniform
	wind_noise_scale = wind_noise_scale # trigger setter to update shader uniform
	wind_speed = wind_speed # trigger setter to update shader uniform
	wind_strength = wind_strength # trigger setter to update shader uniform
	_set_wind_direction_uniform()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		_set_wind_direction_uniform()

func _set_wind_direction_uniform() -> void:
	RenderingServer.global_shader_parameter_set_override(WIND_DIRECTION_UNIFORM, _get_wind_direction())

func _get_wind_direction() -> Vector3:
	var forward: Vector3 = -global_basis.z
	if forward.length() > 0.00001:
		return forward.normalized()

	return Vector3(1.0, 0.0, 0.0)
