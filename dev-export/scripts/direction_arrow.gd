extends Control
class_name DirectionArrow

var direction_angle: float = 0.0
var _bounce_phase: float = 0.0

const ARROW_BASE_COLOR := Color(0.176, 0.478, 0.722, 1.0)    # #2D7AB8
const ARROW_TOP_COLOR := Color(0.529, 0.808, 0.922, 1.0)     # #87CEEB
const ARROW_SHINE_COLOR := Color(1.0, 1.0, 1.0, 0.38)
const BOUNCE_SPEED := 0.72


func set_direction(progress: float, is_forward: bool) -> void:
	direction_angle = progress
	queue_redraw()


func set_angle(angle_rad: float) -> void:
	rotation = angle_rad
	queue_redraw()


func _process(delta: float) -> void:
	_bounce_phase = fmod(_bounce_phase + delta / BOUNCE_SPEED, 1.0)
	queue_redraw()


func _draw() -> void:
	var bounce_y := -5.0 * sin(_bounce_phase * TAU * 0.5)
	var sc := 1.0 + 0.04 * sin(_bounce_phase * TAU * 0.5)

	draw_set_transform(Vector2(0, bounce_y), 0.0, Vector2(sc, sc))

	# Base layer (dark blue)
	var base := PackedVector2Array([
		Vector2(0, -33), Vector2(8, -29), Vector2(35, 4), Vector2(32, 10),
		Vector2(19, 10), Vector2(19, 43), Vector2(12, 50), Vector2(-12, 50),
		Vector2(-19, 43), Vector2(-19, 10), Vector2(-32, 10), Vector2(-35, 4),
		Vector2(-8, -29)
	])
	draw_colored_polygon(base, ARROW_BASE_COLOR)

	# Top layer (light blue)
	var top := PackedVector2Array([
		Vector2(0, -27), Vector2(6, -24), Vector2(27, 2), Vector2(24, 7),
		Vector2(14, 7), Vector2(14, 37), Vector2(8, 43), Vector2(-8, 43),
		Vector2(-14, 37), Vector2(-14, 7), Vector2(-24, 7), Vector2(-27, 2),
		Vector2(-6, -24)
	])
	draw_colored_polygon(top, ARROW_TOP_COLOR)

	# Shine (top highlight)
	var shine := PackedVector2Array([
		Vector2(-1, -20), Vector2(4, -17), Vector2(15, -4), Vector2(12, 0),
		Vector2(-12, 0), Vector2(-15, -4), Vector2(-4, -17)
	])
	draw_colored_polygon(shine, ARROW_SHINE_COLOR)

	draw_set_transform(Vector2.ZERO)
