extends Control
class_name MarkerDot

var in_zone: bool = false

func set_in_zone(value: bool) -> void:
	in_zone = value
	queue_redraw()

