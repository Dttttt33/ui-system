extends Control
class_name MarkerDot

var in_zone: bool = false

const GREEN_OUTER := Color(0.290, 0.608, 0.118, 1.0)
const GREEN_INNER := Color(0.431, 0.773, 0.192, 1.0)
const RED_OUTER := Color(0.769, 0.188, 0.157, 1.0)
const RED_INNER := Color(0.910, 0.271, 0.227, 1.0)
const SHADOW_COLOR := Color(0.290, 0.216, 0.157, 0.24)
const OUTER_RADIUS := 24.0
const INNER_RADIUS := 16.0


func set_in_zone(value: bool) -> void:
	in_zone = value
	queue_redraw()


func _draw() -> void:
	# Shadow ellipse
	draw_set_transform(Vector2(4, 10))
	var shadow_points := PackedVector2Array()
	for i in range(32):
		var angle := float(i) / 32.0 * TAU
		shadow_points.append(Vector2(cos(angle) * 25.0, sin(angle) * 11.0))
	draw_colored_polygon(shadow_points, SHADOW_COLOR)
	draw_set_transform(Vector2.ZERO)

	# Outer circle
	var outer_color := GREEN_OUTER if in_zone else RED_OUTER
	draw_circle(Vector2.ZERO, OUTER_RADIUS, outer_color)

	# Inner circle
	var inner_color := GREEN_INNER if in_zone else RED_INNER
	draw_circle(Vector2.ZERO, INNER_RADIUS, inner_color)
