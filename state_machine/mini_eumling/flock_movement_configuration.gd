class_name FlockMovementConfiguration
extends Resource
## Settings for the flock.

@export_group("Pathfinding")
## Distance from the current path point at which it is considered reached.
## The smaller the value, the more precisely the entity will follow the calculated path.
@export_range(0.1, 100.0, 0.01, "suffix:m") var path_desired_distance: float = 1.0
## Distance from the target at which it is considered reached.
## The smaller the value, the closer the entity will stop at the target.
@export_range(0.1, 100.0, 0.01, "suffix:m") var target_desired_distance: float = 1.0

@export_group("Avoidance")
## Prevent flock members from clipping into each other.
@export var avoidance_enabled: bool = false
## The size of the flock members.
@export_range(0.01, 100.0, 0.01, "suffix:m") var radius: float = 0.5
## How far the avoidance system should search for other flock members.
@export_range(0.1, 10_000.0, 0.1, "suffix:m") var neighbor_distance: float = 50.0
## How many flock members should be considered in the avoidance system.
@export var max_neighbors: int = 10:
	set(value):
		max_neighbors = maxi(value, 1)

@export_group("Debug")
## Whether or not the calculated path should be displayed.
@export var debug_enabled: bool = false
