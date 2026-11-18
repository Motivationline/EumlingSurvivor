class_name ArtisticAbility extends Node3D

@export var duration: float = 3.0

@export var mesh_polygon: MeshPolygon3D
@export var collision_polygon: CollisionPolygon3D

@export var eumling_scaler: EumlingScaler

func _ready() -> void:
	if eumling_scaler: eumling_scaler.setup_and_apply(self)
	# await get_tree().create_timer(duration).timeout
	# queue_free()

func set_polygon(polygon: PackedVector2Array) -> void:
	mesh_polygon.polygon = polygon
	collision_polygon.polygon = polygon
