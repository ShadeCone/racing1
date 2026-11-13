extends Node

class_name Track

var test: int = 0

#@onready var track_path: Path2D = $trackPath

#var _track_curve: Curve2D

#func _ready() -> void:
#	_track_curve = track_path.curve
	
#func get_direction_to_path(from_pos: Vector2) -> Vector2:
#	var closest_offset: float = _track_curve.get_closest_offset(from_pos)
#	return from_pos.direction_to(nearest_point)
	
