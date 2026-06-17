extends Control
class_name MotionFeedbackPanel

@export_file("*.json") var config_path: String = "res://motion_feedback_config.json"
@export var preview_mode: bool = true

@onready var athlete_frame: TextureRect = $PanelFrame/Stage/AthleteFrame
@onready var rom_overlay: RomPathOverlay = $PanelFrame/Stage/RomPathOverlay
@onready var cop_panel: CopPanel = $PanelFrame/Stage/CopPanel
@onready var rom_marker: MarkerDot = $PanelFrame/Stage/RomMarker
@onready var direction_arrow: DirectionArrow = $PanelFrame/Stage/DirectionArrow
@onready var hold_cue: Control = $PanelFrame/Stage/HoldCue

var config: Dictionary = {}
var action_key: String = "row"
var current_action: Dictionary = {}
var current_speed_profile: Dictionary = {}
var current_frames: Array[Texture2D] = []
var current_frame_count: int = 0
var current_frame_fps: float = 30.0
var current_rep_duration: float = 5.0
var current_rep_index: int = 0
var elapsed: float = 0.0
var motion_rom: float = 0.0
var cable_speed_mps: float = 0.0
var cop_value: Vector2 = Vector2.ZERO
var forward: bool = true
var _cycle: float = 0.0


func _ready() -> void:
	_load_config()
	set_exercise(action_key)


func _process(delta: float) -> void:
	if preview_mode:
		_advance_preview(delta)
	_apply_visuals()


func _load_config() -> void:
	var raw := FileAccess.get_file_as_string(config_path)
	var parsed = JSON.parse_string(raw)
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed
	else:
		config = {}


func set_exercise(new_action_key: String) -> void:
	action_key = new_action_key
	current_action = (config.get("actions", {}) as Dictionary).get(action_key, {})
	current_speed_profile = _find_speed_profile(current_action.get("speedProfileKey", ""))
	current_rep_duration = float(current_speed_profile.get("repDuration", 5.0))
	_load_frames()
	_configure_rom_path()
	_configure_cop()


func set_sensor_state(rom_progress: float, speed_mps: float, cop: Vector2) -> void:
	preview_mode = false
	motion_rom = clamp(rom_progress, 0.0, 1.0)
	cable_speed_mps = speed_mps
	cop_value = cop


func set_cop(value: Vector2) -> void:
	cop_value = value


func _configure_rom_path() -> void:
	if not rom_overlay:
		return
	var rom_cfg: Dictionary = current_action.get("romPath", {})
	var path_type: String = rom_cfg.get("type", "line")
	var points: Array = rom_cfg.get("points", [])
	rom_overlay.configure(path_type, points)


func _configure_cop() -> void:
	if not cop_panel:
		return
	var cop_cfg: Dictionary = current_action.get("copPanel", {})
	var center_arr: Array = cop_cfg.get("center", [205, 430])
	var size_arr: Array = cop_cfg.get("size", [260, 145])
	var safe_arr: Array = cop_cfg.get("safeSize", [200, 92])
	var radius: float = float(cop_cfg.get("radius", 36))
	var safe_radius: float = float(cop_cfg.get("safeRadius", 28))
	cop_panel.configure(
		Vector2(center_arr[0], center_arr[1]),
		Vector2(size_arr[0], size_arr[1]),
		Vector2(safe_arr[0], safe_arr[1]),
		radius, safe_radius
	)


func _advance_preview(delta: float) -> void:
	if current_frame_count <= 1:
		return

	elapsed += delta
	var rep_duration := max(current_rep_duration, 0.001)
	var rep_time := fmod(elapsed, rep_duration)
	_cycle = rep_time / rep_duration
	current_rep_index = int(floor(elapsed / rep_duration)) % 3
	forward = _cycle < 0.5

	var frame_phase := clamp(_cycle, 0.0, 1.0)
	var frame_index := int(round(frame_phase * float(current_frame_count - 1)))
	var frame_motion := float(frame_index) / float(max(current_frame_count - 1, 1))
	motion_rom = frame_motion if frame_motion <= 0.5 else 1.0 - frame_motion
	motion_rom = clamp(motion_rom * 2.0, 0.02, 1.0)

	# COP preview: gentle drift
	var t := elapsed + float(hash(action_key) % 100) * 0.7
	cop_value = Vector2(
		sin(t * 1.35) * 0.26 + sin(t * 2.8) * 0.07,
		cos(t * 1.15) * 0.11 + sin(t * 3.2) * 0.04
	)


func _apply_visuals() -> void:
	# Athlete frame
	if current_frames.size() > 0 and athlete_frame:
		var fi := int(round(clamp(_cycle, 0.0, 1.0) * float(current_frames.size() - 1)))
		fi = clamp(fi, 0, current_frames.size() - 1)
		athlete_frame.texture = current_frames[fi]

	# ROM overlay
	if rom_overlay:
		var zone := _get_speed_zone(current_speed_profile, _cycle)
		rom_overlay.set_motion(motion_rom, zone.start, zone.end, forward)

	# Marker position + zone color
	if rom_marker and rom_overlay:
		var pos := rom_overlay.sample_at(motion_rom)
		rom_marker.position = pos
		var zone := _get_speed_zone(current_speed_profile, _cycle)
		rom_marker.set_in_zone(motion_rom >= zone.start and motion_rom <= zone.end)

	# Direction arrow position + rotation
	if direction_arrow and rom_overlay:
		var pos := rom_overlay.sample_at(motion_rom)
		direction_arrow.position = pos + Vector2(62, 0)
		var dir_sign := 1.0 if forward else -1.0
		var next_t := clamp(motion_rom + dir_sign * 0.02, 0.0, 1.0)
		var next_pos := rom_overlay.sample_at(next_t)
		var angle := (next_pos - pos).angle() + PI * 0.5
		direction_arrow.set_angle(angle)

	# COP panel
	if cop_panel:
		cop_panel.set_cop(cop_value)

	# Hold cue (hidden)
	if hold_cue:
		hold_cue.visible = false


func _find_speed_profile(profile_key: String) -> Dictionary:
	var speed_range := (config.get("standardCableSpeedRange", {}) as Dictionary).get("exercises", [])
	for item in speed_range:
		if item is Dictionary and item.get("exercise", "") == profile_key:
			return item
	return {}


func _get_speed_zone(standard: Dictionary, cycle: float) -> Dictionary:
	if standard.is_empty():
		return {"start": 0.0, "end": 1.0}

	var forward_phase := cycle < 0.5
	var half_phase := cycle * 2.0 if forward_phase else (cycle - 0.5) * 2.0
	var spd_range: Dictionary = standard.get("pullOutSpeed", {}) if forward_phase else standard.get("returnInSpeed", {})
	var min_speed := float(spd_range.get("min", 0.0))
	var max_speed := float(spd_range.get("max", 0.0))
	var avg_speed := (min_speed + max_speed) * 0.5
	if avg_speed <= 0.0:
		return {"start": 0.0, "end": 1.0}

	var min_progress := (min_speed / avg_speed) * half_phase
	var max_progress := (max_speed / avg_speed) * half_phase
	var start := min(min_progress, max_progress)
	var end := max(min_progress, max_progress)
	var center := half_phase
	var min_span := 0.14

	if not forward_phase:
		start = min(1.0 - max_progress, 1.0 - min_progress)
		end = max(1.0 - max_progress, 1.0 - min_progress)
		center = 1.0 - half_phase

	start = clamp(start, 0.0, 1.0)
	end = clamp(end, 0.0, 1.0)

	if end - start < min_span:
		start = center - min_span * 0.5
		end = center + min_span * 0.5

	if start < 0.0:
		end -= start
		start = 0.0

	if end > 1.0:
		start -= end - 1.0
		end = 1.0

	return {
		"start": clamp(start, 0.0, 1.0 - min_span),
		"end": clamp(end, min_span, 1.0)
	}


func _load_frames() -> void:
	current_frames.clear()
	current_frame_count = int(current_action.get("athleteFrames", {}).get("count", 0))
	current_frame_fps = float(current_action.get("athleteFrames", {}).get("fps", 30))
	var frame_dir: String = String(current_action.get("athleteFrames", {}).get("dir", ""))
	var prefix: String = String(current_action.get("athleteFrames", {}).get("prefix", ""))

	if frame_dir.is_empty() or prefix.is_empty() or current_frame_count <= 0:
		return

	for i in range(current_frame_count):
		var file_path := "%s/%s_%05d.png" % [frame_dir, prefix, i]
		var texture := load(file_path)
		if texture is Texture2D:
			current_frames.append(texture)
