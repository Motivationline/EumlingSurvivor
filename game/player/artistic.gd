extends Ability

@export var tail_duration_base: float = 1.0
@export var tail_duration_additional: float = 0.5

@export var damage_base: float = 10.0
@export var damage_additional: float = 5.0

@export var squared_distance_to_check: float = 0.1
@export var minimum_area_to_trigger: float = 0.5

@onready var tail_curve: Curve3D = $Tail.curve
@onready var hitbox_polygon: CollisionPolygon3D = $CollisionArea/Polygon
@onready var visible_polygon: CSGPolygon3D = $VisiblePolygon

var tail_duration: float = 1.0

var points: PackedVector3Array = []
var points_2d: PackedVector2Array = []
var times: PackedFloat32Array = []

func _ready() -> void:
	_type = Enum.EUMLING_TYPE.ARTISTIC
	super ()
	
func _update():
	if amt_eumlings == 0 and points.size() > 0:
		clear_points()
	tail_duration = tail_duration_base + (amt_eumlings - 1) * tail_duration_additional
	$CollisionArea.damage = damage_base + (amt_eumlings - 1) * damage_additional

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
	if not prev_point.is_equal_approx(owner.global_position) or points.size() == 0:
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
				visible_polygon.polygon = polygon
				
				var hitbox_poly: PackedVector2Array = []
				hitbox_poly.resize(ceili(polygon.size() / 4.0))
				for k in polygon.size():
					if k % 4 == 0:
						hitbox_poly[floori(k / 4.0)] = polygon[k]
				hitbox_polygon.polygon = hitbox_poly
				hitbox_polygon.global_position.y = owner.global_position.y
				visible_polygon.global_position.y = owner.global_position.y
				clear_points()
				break

func clear_points():
	# clean up existing stuff
	points.clear()
	points_2d.clear()
	times.clear()
	tail_curve.clear_points()
