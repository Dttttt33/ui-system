extends Control
class_name RomPathOverlay

var rom_path_type: String = "line"
var rom_path_points: PackedVector2Array = PackedVector2Array()
var motion_rom: float = 0.0
var zone_start: float = 0.0
var zone_end: float = 1.0
var forward: bool = true

const SAMPLES := 100
const DASH := 4.0
const GAP := 14.0
const PATH_COLOR := Color(0.529, 0.808, 0.922, 1.0)
const ACTIVE_COLOR := Color(1.0, 1.0, 1.0, 0.88)
const PROGRESS_COLOR := Color(0.290, 0.616, 0.851, 0.5)
const ZONE_COLOR := Color(0.431, 0.773, 0.192, 0.82)
const PATH_WIDTH := 10.0
const PROGRESS_WIDTH := 42.0
const ZONE_WIDTH := 58.0

var _points: PackedVector2Array = PackedVector2Array()
var _cum_lengths: PackedFloat64Array = PackedFloat64Array()
var _total_length: float = 0.0


func configure(path_type: String, points: Array) -> void:
	rom_path_type = path_type
	rom_path_points.clear()
	for p in points:
		rom_path_points.append(Vector2(p[0], p[1]))
	_build_samples()
	queue_redraw()


func set_motion(progress: float, start: float, end: float, is_forward: bool) -> void:
	motion_rom = clamp(progress, 0.0, 1.0)
	zone_start = clamp(start, 0.0, 1.0)
	zone_end = clamp(end, 0.0, 1.0)
	forward = is_forward
	queue_redraw()


func sample_at(t: float) -> Vector2:
	if _points.is_empty():
		return _sample_raw(clamp(t, 0.0, 1.0))
	var target := clamp(t, 0.0, 1.0) * _total_length
	for i in range(1, _cum_lengths.size()):
		if _cum_lengths[i] >= target:
			var seg_len := _cum_lengths[i] - _cum_lengths[i - 1]
			var local_t := 0.0 if seg_len < 0.001 else (target - _cum_lengths[i - 1]) / seg_len
			return _points[i - 1].lerp(_points[i], local_t)
	return _points[_points.size() - 1]


func get_total_length() -> float:
	return _total_length


func _build_samples() -> void:
	_points.clear()
	_cum_lengths.clear()
	_total_length = 0.0
	if rom_path_points.size() < 2:
		return
	for i in range(SAMPLES + 1):
		_points.append(_sample_raw(float(i) / float(SAMPLES)))
	_cum_lengths.append(0.0)
	for i in range(1, _points.size()):
		_total_length += _points[i].distance_to(_points[i - 1])
		_cum_lengths.append(_total_length)


func _sample_raw(t: float) -> Vector2:
	t = clamp(t, 0.0, 1.0)
	if rom_path_type == "quadratic" and rom_path_points.size() >= 3:
		var u := 1.0 - t
		return u * u * rom_path_points[0] + 2.0 * u * t * rom_path_points[1] + t * t * rom_path_points[2]
	elif rom_path_points.size() >= 2:
		return rom_path_points[0].lerp(rom_path_points[1], t)
	return Vector2.ZERO


func _draw() -> void:
	if _points.size() < 2:
		return
	_draw_segment(zone_start, zone_end, ZONE_COLOR, ZONE_WIDTH)
	if forward:
		_draw_segment(0.0, motion_rom, PROGRESS_COLOR, PROGRESS_WIDTH)
	else:
		_draw_segment(motion_rom, 1.0, PROGRESS_COLOR, PROGRESS_WIDTH)
	_draw_dashed(0.0, 1.0, PATH_COLOR, PATH_WIDTH)
	if forward:
		_draw_dashed(0.0, motion_rom, ACTIVE_COLOR, PATH_WIDTH)
	else:
		_draw_dashed(motion_rom, 1.0, ACTIVE_COLOR, PATH_WIDTH)


func _draw_segment(t0: float, t1: float, color: Color, width: float) -> void:
	if t1 <= t0:
		return
	var pts := PackedVector2Array()
	var steps := maxi(int(SAMPLES * (t1 - t0)), 2)
	for i in range(steps + 1):
		pts.append(sample_at(t0 + (t1 - t0) * float(i) / float(steps)))
	if pts.size() >= 2:
		draw_polyline(pts, color, width, true)


func _draw_dashed(t0: float, t1: float, color: Color, width: float) -> void:
	if t1 <= t0 or _total_length <= 0.0:
		return
	var seg_total := _total_length * (t1 - t0)
	var drawn := 0.0
	var on := true
	while drawn < seg_total:
		var chunk := minf(DASH if on else GAP, seg_total - drawn)
		if on and chunk > 0.5:
			var s := t0 + drawn / _total_length
			var e := t0 + (drawn + chunk) / _total_length
			draw_line(sample_at(clamp(s, 0.0, 1.0)), sample_at(clamp(e, 0.0, 1.0)), color, width, true)
		drawn += chunk
		on = not on
