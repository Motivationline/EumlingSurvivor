extends Ability

@export var tail_duration: float = 1.0
@export var squared_distance_to_check: float = 0.1
@export var minimum_area_to_trigger: float = 0.5

@onready var tail_curve: Curve3D = $Tail.curve

var damage: float = 1.0

var points: PackedVector3Array = []
var points_2d: PackedVector2Array = []
var times: PackedFloat32Array = []

@export var strength_ability: PackedScene
var strength_ability_instance: ArtisticAbility

@export var eumling_scaler: EumlingScaler

func _ready() -> void:
	_type = Enum.EUMLING_TYPE.ARTISTIC
	super ()
	if eumling_scaler: eumling_scaler.setup_and_apply(self)

func level_start() -> void:
	clear_points()
	strength_ability_instance = strength_ability.instantiate()
	var level = get_tree().get_first_node_in_group("Level")
	if level:
		level.add_child(strength_ability_instance)
		strength_ability_instance.global_position.y = owner.global_position.y


func _update():
	if amt_eumlings == 0 and points.size() > 0:
		clear_points()

var current_time: float = 0.0
var prev_point: Vector3 = Vector3.ZERO
func _process(delta: float) -> void:	
	if amt_eumlings == 0: 
		return
	
	# potentially add new points
	current_time += delta
	var cutoff_time: float = current_time - tail_duration
	for i in times.size():
		var time: float = times[i]
		if time >= cutoff_time:
			times = times.slice(i)
			points = points.slice(i)
			points_2d = points_2d.slice(i)
			for k in i:
				tail_curve.remove_point(0)
			break
	if prev_point.distance_squared_to(owner.global_position) > squared_distance_to_check or points.size() == 0:
		prev_point = owner.global_position
		times.append(current_time)
		points.append(prev_point)
		points_2d.append(Vector2(prev_point.x, prev_point.z))
		tail_curve.add_point(prev_point)

	# check if we have an overlap to trigger the ability
	# the way it works for now (probably could be improved a lot) is that it checks whether there is a close point in the list that's not the latest point
	# then checks whether this has a large enough area to then trigger the event.
	# https://en.wikipedia.org/wiki/Shoelace_formula

		var current_point_2d: Vector2 = Vector2(prev_point.x, prev_point.z)
		for i in points_2d.size() - 1:
			var point = points_2d[i]
			if current_point_2d.distance_squared_to(point) < squared_distance_to_check:
				# close point, now calculate the resulting area
				var area : float = 0.0
				for n in range(i, points_2d.size()):
					var point_i: Vector2 = points_2d[n]
					var point_i_1: Vector2 = points_2d[n + 1] if n + 1 < points_2d.size() else points_2d[i]
					area += (point_i.y + point_i_1.y) * (point_i.x - point_i_1.x)

				area /= 2
				if absf(area) < minimum_area_to_trigger:
					# we're checking from the furthest possible point, if this one doesn't work, we don't need to check futher.
					break
				var polygon = points_2d.slice(i)
				update_area(strength_ability_instance, polygon)
				clear_points()
				break

func clear_points():
	# clean up existing stuff
	points.clear()
	points_2d.clear()
	times.clear()
	tail_curve.clear_points()

func update_area(area: ArtisticAbility, polygon_points: PackedVector2Array):
	area.polygon = polygon_points

	# reduce hitbox polygons (currently not needed, but maybe again when we up the amount of points in the poly again)
	# var hitbox_polygon = CollisionPolygon3D.new()
	# var hitbox_poly: PackedVector2Array = []
	# hitbox_poly.resize(ceili(polygon_points.size() / 4.0))
	# for k in polygon_points.size():
	# 	if k % 4 == 0:
	# 		hitbox_poly[floori(k / 4.0)] = polygon_points[k]
	# hitbox_polygon.polygon = hitbox_poly
