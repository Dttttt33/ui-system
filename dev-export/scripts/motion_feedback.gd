extends Control
class_name MotionFeedbackPanel

@export_file("*.json") var config_path: String = "res://motion_feedback_config.json"
@export var preview_mode: bool = true

@onready var athlete_frame: TextureRect = $PanelFrame/Stage/AthleteFrame
@onready var rom_overlay: Control = $PanelFrame/Stage/RomPathOverlay
@onready var cop_panel: Control = $PanelFrame/Stage/CopPanel
@onready var rom_marker: Control = $PanelFrame/Stage/RomMarker
@onready var direction_arrow: Control = $PanelFrame/Stage/DirectionArrow
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

func set_sensor_state(rom_progress: float, speed_mps: float, cop: Vector2) -> void:
	preview_mode = false
	motion_rom = clamp(rom_progress, 0.0, 1.0)
	cable_speed_mps = speed_mps
	cop_value = cop

func set_cop(value: Vector2) -> void:
	cop_value = value

func _advance_preview(delta: float) -> void:
	if current_frame_count <= 1:
		return

	elapsed += delta
	var rep_duration := max(current_rep_duration, 0.001)
	var rep_time := fmod(elapsed, rep_duration)
	var cycle := rep_time / rep_duration
	current_rep_index = int(floor(elapsed / rep_duration)) % 3

	var frame_phase := clamp(cycle, 0.0, 1.0)
	var frame_index := int(round(frame_phase * float(current_frame_count - 1)))
	var frame_motion := float(frame_index) / float(max(current_frame_count - 1, 1))
	motion_rom = frame_motion if frame_motion <= 0.5 else 1.0 - frame_motion
	motion_rom = clamp(motion_rom * 2.0, 0.02, 1.0)
	forward = cycle < 0.5

func _apply_visuals() -> void:
	if current_frames.size() > 0 and athlete_frame:
		var frame_index := int(round(motion_rom * float(current_frames.size() - 1)))
		frame_index = clamp(frame_index, 0, current_frames.size() - 1)
		athlete_frame.texture = current_frames[frame_index]

	if rom_overlay and rom_overlay.has_method("set_motion"):
		var zone := _get_speed_zone(current_speed_profile, motion_rom)
		rom_overlay.call("set_motion", motion_rom, zone.start, zone.end, forward)

	if rom_marker and rom_marker.has_method("set_in_zone"):
		var zone := _get_speed_zone(current_speed_profile, motion_rom)
		rom_marker.call("set_in_zone", motion_rom >= zone.start and motion_rom <= zone.end)

	if direction_arrow and direction_arrow.has_method("set_direction"):
		direction_arrow.call("set_direction", motion_rom, forward)

	if cop_panel and cop_panel.has_method("set_cop"):
		cop_panel.call("set_cop", cop_value)

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
	var range := standard.get("pullOutSpeed", {}) if forward_phase else standard.get("returnInSpeed", {})
	var min_speed := float(range.get("min", 0.0))
	var max_speed := float(range.get("max", 0.0))
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
