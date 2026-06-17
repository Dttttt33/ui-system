extends Control
class_name DirectionArrow

var direction_angle: float = 0.0

func set_direction(progress: float, forward: bool) -> void:
	direction_angle = progress
	rotation = 0.0 if forward else PI
	queue_redraw()

