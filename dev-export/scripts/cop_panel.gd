extends Control
class_name CopPanel

var cop_center: Vector2 = Vector2(205, 430)
var cop_size: Vector2 = Vector2(260, 145)
var cop_safe_size: Vector2 = Vector2(200, 92)
var cop_radius: float = 36.0
var cop_safe_radius: float = 28.0
var cop_value: Vector2 = Vector2.ZERO

const PLATE_FILL := Color(0.933, 0.945, 0.910, 0.74)
const PLATE_STROKE := Color(0.282, 0.325, 0.267, 0.56)
const SAFE_FILL := Color(0.431, 0.773, 0.192, 0.17)
const SAFE_STROKE := Color(0.290, 0.608, 0.118, 0.62)
const CROSS_COLOR := Color(0.290, 0.216, 0.157, 0.16)
const TRAIL_COLOR := Color(0.290, 0.608, 0.118, 0.32)
const DOT_COLOR := Color(0.290, 0.608, 0.118, 1.0)
const PING_COLOR := Color(0.431, 0.773, 0.192, 0.58)

var _trail_prev: Vector2 = Vector2.ZERO
var _ping_phase: float = 0.0


func configure(center: Vector2, panel_size: Vector2, safe_size: Vector2, radius: float = 36.0, safe_radius: float = 28.0) -> void:
	cop_center = center
	cop_size = panel_size
	cop_safe_size = safe_size
	cop_radius = radius
	cop_safe_radius = safe_radius
	queue_redraw()


func set_cop(value: Vector2) -> void:
	_trail_prev = cop_center + Vector2(cop_value.x * cop_size.x * 0.5, cop_value.y * cop_size.y * 0.5)
	cop_value = value
	queue_redraw()


func _process(delta: float) -> void:
	_ping_phase = fmod(_ping_phase + delta / 1.1, 1.0)
	queue_redraw()


func _draw() -> void:
	var half := cop_size * 0.5
	var rect := Rect2(cop_center - half, cop_size)

	# Plate background
	draw_rect(rect, PLATE_FILL, true)
	draw_rect(rect, PLATE_STROKE, false, 5.0)

	# Safe zone (dashed border)
	var safe_half := cop_safe_size * 0.5
	var safe_rect := Rect2(cop_center - safe_half, cop_safe_size)
	draw_rect(safe_rect, SAFE_FILL, true)
	draw_rect(safe_rect, SAFE_STROKE, false, 4.0)

	# Cross lines
	draw_line(Vector2(rect.position.x, cop_center.y), Vector2(rect.end.x, cop_center.y), CROSS_COLOR, 3.0)
	draw_line(Vector2(cop_center.x, rect.position.y), Vector2(cop_center.x, rect.end.y), CROSS_COLOR, 3.0)

	# Current dot position
	var dot_pos := cop_center + Vector2(cop_value.x * half.x, cop_value.y * half.y)

	# Trail
	draw_line(_trail_prev if _trail_prev != Vector2.ZERO else cop_center, dot_pos, TRAIL_COLOR, 9.0)

	# Ping ring (animated)
	var ping_scale := 0.55 + _ping_phase * 1.3
	var ping_alpha := 0.58 * (1.0 - _ping_phase)
	var ping_color := Color(PING_COLOR.r, PING_COLOR.g, PING_COLOR.b, ping_alpha)
	draw_arc(dot_pos, 15.0 * ping_scale, 0.0, TAU, 32, ping_color, 4.0)

	# Dot
	draw_circle(dot_pos, 10.0, DOT_COLOR)
