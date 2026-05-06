class_name ArtisticAbility extends Node3D

@export var color: Color

@export var polygons: Array[CSGPolygon3D]
@export var collisions: Array[CollisionPolygon3D]

var polygon: PackedVector2Array:
	set(value):
		polygon = value
		for poly in polygons:
			poly.polygon = polygon
			poly.global_position.y = owner.global_position.y
		for coll in collisions:
			coll.polygon = polygon
			coll.global_position.y = owner.global_position.y
