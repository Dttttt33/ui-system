class_name MotionFeedbackUI
extends Control

# =============================================================================
# Motion Feedback — ROM path + CoP + Pace
# Drives marker along ROM path, animates CoP dot, calculates speed zone
# =============================================================================

@export var action_key: String = "row"
@export var hold_every: int = 3
@export var hold_visuals_enabled: bool = false

@onready var rom_path: Line2D = $StagePanel/AthleteArea/ROMPath
@onready var rom_zone: Line2D = $StagePanel/AthleteArea/ROMZone
@onready var rom_progress: Line2D = $StagePanel/AthleteArea/ROMProgress
@onready var marker: Control = $StagePanel/AthleteArea/Marker
@onready var marker_outer: ColorRect = $StagePanel/AthleteArea/Marker/MarkerOuter
@onready var marker_inner: ColorRect = $StagePanel/AthleteArea/Marker/MarkerInner
@onready var arrow: TextureRect = $StagePanel/AthleteArea/Arrow
@onready var hold_label: Label = $StagePanel/AthleteArea/HoldLabel
@onready var cop_dot: ColorRect = $StagePanel/CoPWidget/CoPDot
@onready var cop_safe: ColorRect = $StagePanel/CoPWidget/SafeZone
@onready var rom_value: Label = $MetricsPanel/ROMCard/VBox/Value
@onready var pace_value: Label = $MetricsPanel/PaceCard/VBox/Value
@onready var cop_value: Label = $MetricsPanel/CoPCard/VBox/Value
@onready var rom_fill: ColorRect = $MetricsPanel/ROMCard/VBox/Track/Fill
@onready var pace_fill: ColorRect = $MetricsPanel/PaceCard/VBox/Track/Fill
@onready var cop_fill: ColorRect = $MetricsPanel/CoPCard/VBox/Track/Fill

const COLOR_GREEN = Color(0.431, 0.773, 0.192, 1)
const COLOR_GREEN_DARK = Color(0.290, 0.608, 0.118, 1)
const COLOR_RED = Color(0.910, 0.271, 0.227, 1)
const COLOR_RED_DARK = Color(0.769, 0.188, 0.157, 1)

var current_action: Dictionary
var path_points: PackedVector2Array
var path_length: float = 0.0
var elapsed: float = 0.0
var cop_base: Vector2
var rom_percent: float = 0.68
var cop_percent: float = 0.82
var pace_rating: String = "GOOD"


func _ready() -> void:
	current_action = ActionDatabase.get_action(action_key)
	if current_action.is_empty():
		current_action = ActionDatabase.get_action("row")
	_setup_path()
	cop_base = Vector2(current_action.cop_x, current_action.cop_y)


func _process(delta: float) -> void:
	elapsed += delta
	_update_rom_motion()
	_update_cop()
	_update_metrics()


func _setup_path() -> void:
	path_points = _parse_path_string(current_action.rom_path)
	rom_path.points = path_points
	path_length = _calculate_path_length(path_points)


func _update_rom_motion() -> void:
	var rep_duration: float = current_action.get("rep_duration", 3.3)
	var total_cycle_time: float = rep_duration * hold_every
	var cycle_elapsed: float = fmod(elapsed, total_cycle_time)
	var rep_index: int = int(cycle_elapsed / rep_duration)
	var cycle: float = fmod(cycle_elapsed, rep_duration) / rep_duration

	var hold_this_rep: bool = hold_visuals_enabled and rep_index == hold_every - 1
	var is_hold: bool = hold_this_rep and cycle >= 0.48 and cycle < 0.68
	var forward: bool = cycle < 0.5 if not hold_this_rep else cycle < 0.68

	var phase: float
	if hold_this_rep:
		if cycle < 0.48:
			phase = cycle / 0.48
		elif is_hold:
			phase = 1.0
		else:
			phase = (1.0 - cycle) / 0.32
	else:
		if cycle < 0.5:
			phase = cycle / 0.5
		else:
			phase = (1.0 - cycle) / 0.5

	var rom: float = clampf(_ease_in_out(phase), 0.02, 1.0)
	var distance: float = path_length * rom
	var point: Vector2 = _get_point_at_distance(distance)

	marker.position = point

	# Zone check
	var standard_speed = current_action.get("standard_speed", null)
	var zone_start: float
	var zone_end: float
	if standard_speed != null:
		var zone = _get_standard_speed_zone(standard_speed, cycle)
		zone_start = zone.x
		zone_end = zone.y
	else:
		var direction_sign: float = 1.0 if forward else -1.0
		var target: float = clampf(rom + direction_sign * 0.14, 0.1, 0.9)
		zone_start = clampf(target - 0.11, 0.0, 0.78)
		zone_end = zone_start + 0.22

	var in_zone: bool = rom >= zone_start and rom <= zone_end

	# Marker color
	if in_zone:
		marker_outer.color = COLOR_GREEN_DARK
		marker_inner.color = COLOR_GREEN
	else:
		marker_outer.color = COLOR_RED_DARK
		marker_inner.color = COLOR_RED

	# Arrow / Hold visibility
	if hold_visuals_enabled and is_hold:
		arrow.visible = false
		hold_label.visible = true
	else:
		arrow.visible = true
		hold_label.visible = false

	# Update arrow position
	if arrow.visible:
		arrow.position = point + Vector2(50, -30)

	hold_label.position = point + Vector2(50, -18)

	# Update rom percent based on current motion
	rom_percent = rom


func _update_cop() -> void:
	var time: float = elapsed
	var x: float = cop_base.x + sin(time * 1.35) * 34.0 + sin(time * 2.8) * 9.0
	var y: float = cop_base.y + cos(time * 1.15) * 8.0 + sin(time * 3.2) * 3.0

	# Map to local widget coordinates
	var cop_widget: Control = $StagePanel/CoPWidget
	var local_x: float = x - cop_widget.position.x
	var local_y: float = y - cop_widget.position.y
	cop_dot.position = Vector2(local_x - 10, local_y - 10)

	# Check if inside safe zone
	var safe_rect: Rect2 = cop_safe.get_rect()
	var in_safe: bool = safe_rect.has_point(Vector2(local_x, local_y))
	cop_percent = 0.85 if in_safe else 0.55


func _update_metrics() -> void:
	rom_value.text = "%d%%" % int(rom_percent * 100)
	cop_value.text = "%d%%" % int(cop_percent * 100)
	pace_value.text = pace_rating

	# Fill widths (max ~180px track width)
	rom_fill.custom_minimum_size.x = rom_percent * 180.0
	cop_fill.custom_minimum_size.x = cop_percent * 180.0
	pace_fill.custom_minimum_size.x = 0.7 * 180.0


# === Utility ===

func _ease_in_out(t: float) -> float:
	if t < 0.5:
		return 2.0 * t * t
	return 1.0 - pow(-2.0 * t + 2.0, 2) / 2.0


func _parse_path_string(path_str: String) -> PackedVector2Array:
	var points := PackedVector2Array()
	var parts: PackedStringArray = path_str.split(" ")
	var i: int = 0
	while i < parts.size():
		var cmd: String = parts[i]
		if cmd == "M" or cmd == "L":
			i += 1
			var coords: PackedStringArray = parts[i].split(",") if parts[i].contains(",") else PackedStringArray()
			if coords.size() == 2:
				points.append(Vector2(float(coords[0]), float(coords[1])))
			elif i + 1 < parts.size():
				points.append(Vector2(float(parts[i]), float(parts[i + 1])))
				i += 1
		elif cmd.begins_with("M") or cmd.begins_with("L"):
			var num_part: String = cmd.substr(1)
			var coords: PackedStringArray = num_part.split(",") if num_part.contains(",") else PackedStringArray()
			if coords.size() == 2:
				points.append(Vector2(float(coords[0]), float(coords[1])))
		elif cmd == "Q":
			# Quadratic bezier: control point + end point, sample intermediate
			i += 1
			var ctrl := Vector2.ZERO
			var end_pt := Vector2.ZERO
			if parts[i].contains(","):
				var c: PackedStringArray = parts[i].split(",")
				ctrl = Vector2(float(c[0]), float(c[1]))
			else:
				ctrl = Vector2(float(parts[i]), float(parts[i + 1]))
				i += 1
			i += 1
			if parts[i].contains(","):
				var e: PackedStringArray = parts[i].split(",")
				end_pt = Vector2(float(e[0]), float(e[1]))
			else:
				end_pt = Vector2(float(parts[i]), float(parts[i + 1]))
				i += 1
			# Sample quadratic bezier
			var start_pt: Vector2 = points[points.size() - 1] if points.size() > 0 else Vector2.ZERO
			for s in range(1, 11):
				var t: float = float(s) / 10.0
				var p: Vector2 = (1.0 - t) * (1.0 - t) * start_pt + 2.0 * (1.0 - t) * t * ctrl + t * t * end_pt
				points.append(p)
		i += 1
	return points


func _calculate_path_length(points: PackedVector2Array) -> float:
	var total: float = 0.0
	for i in range(1, points.size()):
		total += points[i - 1].distance_to(points[i])
	return total


func _get_point_at_distance(dist: float) -> Vector2:
	if path_points.size() < 2:
		return path_points[0] if path_points.size() > 0 else Vector2.ZERO
	var accumulated: float = 0.0
	for i in range(1, path_points.size()):
		var seg_len: float = path_points[i - 1].distance_to(path_points[i])
		if accumulated + seg_len >= dist:
			var t: float = (dist - accumulated) / seg_len if seg_len > 0 else 0.0
			return path_points[i - 1].lerp(path_points[i], t)
		accumulated += seg_len
	return path_points[path_points.size() - 1]


func _get_standard_speed_zone(standard: Dictionary, cycle: float) -> Vector2:
	var forward: bool = cycle < 0.5
	var half_phase: float = cycle * 2.0 if forward else (cycle - 0.5) * 2.0
	var range_dict: Dictionary = standard.pull_out if forward else standard.return_in
	var avg_speed: float = (range_dict.min_speed + range_dict.max_speed) / 2.0
	var min_progress: float = (range_dict.min_speed / avg_speed) * half_phase if avg_speed > 0 else half_phase
	var max_progress: float = (range_dict.max_speed / avg_speed) * half_phase if avg_speed > 0 else half_phase

	var start: float
	var end: float
	if forward:
		start = minf(min_progress, max_progress)
		end = maxf(min_progress, max_progress)
	else:
		start = minf(1.0 - max_progress, 1.0 - min_progress)
		end = maxf(1.0 - max_progress, 1.0 - min_progress)

	var min_span: float = 0.14
	start = clampf(start, 0.0, 1.0)
	end = clampf(end, 0.0, 1.0)

	if end - start < min_span:
		var center: float = half_phase if forward else 1.0 - half_phase
		start = center - min_span / 2.0
		end = center + min_span / 2.0

	if start < 0.0:
		end -= start
		start = 0.0
	if end > 1.0:
		start -= end - 1.0
		end = 1.0

	return Vector2(
		clampf(start, 0.0, 1.0 - min_span),
		clampf(end, min_span, 1.0)
	)


# === External API ===

func set_action(key: String) -> void:
	action_key = key
	current_action = ActionDatabase.get_action(key)
	_setup_path()
	cop_base = Vector2(current_action.cop_x, current_action.cop_y)
	elapsed = 0.0


func set_rom_percent(value: float) -> void:
	rom_percent = clampf(value, 0.0, 1.0)


func set_cop_percent(value: float) -> void:
	cop_percent = clampf(value, 0.0, 1.0)


func set_pace(rating: String) -> void:
	pace_rating = rating
