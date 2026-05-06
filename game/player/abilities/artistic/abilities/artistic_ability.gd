class_name ArtisticAbility extends Node3D

@export var color: Color

@export var polygons: Array[CSGPolygon3D]
@export var collisions: Array[CollisionPolygon3D]
@export var duration: float = 3.0

@export var eumling_scaler: EumlingScaler

var polygon: PackedVector2Array:
	set(value):
		polygon = value
		for poly in polygons:
			poly.polygon = polygon
		for coll in collisions:
			coll.polygon = polygon

func _ready() -> void:
	if eumling_scaler: eumling_scaler.setup_and_apply(self)
	await get_tree().create_timer(duration).timeout
	queue_free()
