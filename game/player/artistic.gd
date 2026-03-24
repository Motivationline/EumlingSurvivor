extends Ability

@export var tail_duration_base: float = 1.0
@export var tail_duration_additional: float = 0.5

var tail_duration: float = 1.0

var points: PackedVector3Array = []
var times: PackedFloat32Array = []

func _ready() -> void:
	_type = Enum.EUMLING_TYPE.ARTISTIC
	super ()
	
func _update():
	if amt_eumlings == 0 and points.size() > 0:
		# TODO clean up existing stuff
		pass
	tail_duration = tail_duration_base + amt_eumlings * tail_duration_additional


var current_time: float = 0.0
var prev_point: Vector3 = Vector3.ZERO
func _process(delta: float) -> void:	
	if amt_eumlings == 0: 
		return
	current_time += delta
	var cutoff_time = current_time - tail_duration
	for i in times.size():
		var time = times[i]
		if time >= cutoff_time:
			times = times.slice(i)
			points = points.slice(i)
			for k in i:
				$Tail.curve.remove_point(0)
			break
	if not prev_point.is_equal_approx(owner.global_position) or points.size() == 0:
		prev_point = owner.global_position
		times.append(current_time)
		points.append(prev_point)
		$Tail.curve.add_point(prev_point)
