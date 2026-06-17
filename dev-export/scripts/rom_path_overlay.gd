extends Control
class_name RomPathOverlay

var motion_rom: float = 0.0
var zone_start: float = 0.0
var zone_end: float = 1.0
var forward: bool = true

func set_motion(progress: float, start: float, end: float, is_forward: bool) -> void:
	motion_rom = clamp(progress, 0.0, 1.0)
	zone_start = clamp(start, 0.0, 1.0)
	zone_end = clamp(end, 0.0, 1.0)
	forward = is_forward
	queue_redraw()

