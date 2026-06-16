class_name ActionDatabase
extends RefCounted

# =============================================================================
# 7 Action definitions — ROM path, pose, CoP position, speed standards
# Translated from cop-rom-speed-ui-versions.html
# =============================================================================

static var _actions: Dictionary = {}


static func _ensure_loaded() -> void:
	if not _actions.is_empty():
		return
	_actions = {
		"row": {
			"name": "LUNGE SINGLE-ARM ROW",
			"pose": "row",
			"rom_path": "M500 330 L555 235",
			"hold_x": 555.0,
			"hold_y": 235.0,
			"cop_x": 205.0,
			"cop_y": 430.0,
			"cop_w": 260.0,
			"cop_h": 145.0,
			"cop_safe_w": 200.0,
			"cop_safe_h": 92.0,
			"rep_duration": 5.0,
			"standard_speed": {
				"pull_out": { "min_speed": 0.18, "max_speed": 0.23 },
				"return_in": { "min_speed": 0.12, "max_speed": 0.15 }
			},
			"athlete": {
				"head": Vector2(306, 168),
				"shoulder": Vector2(330, 230),
				"hip": Vector2(360, 318),
				"left_foot": Vector2(258, 445),
				"right_foot": Vector2(448, 438),
				"handle": Vector2(500, 330)
			}
		},
		"raise": {
			"name": "SINGLE-ARM LATERAL RAISE",
			"pose": "raise",
			"rom_path": "M405 390 Q540 350 602 225",
			"hold_x": 602.0,
			"hold_y": 225.0,
			"cop_x": 330.0,
			"cop_y": 469.0,
			"cop_w": 300.0,
			"cop_h": 72.0,
			"cop_safe_w": 124.0,
			"cop_safe_h": 40.0,
			"rep_duration": 3.3,
			"standard_speed": null,
			"athlete": {
				"head": Vector2(300, 150),
				"shoulder": Vector2(312, 220),
				"hip": Vector2(318, 302),
				"left_foot": Vector2(266, 444),
				"right_foot": Vector2(404, 438),
				"handle": Vector2(405, 390)
			}
		},
		"swing": {
			"name": "SQUAT SWING",
			"pose": "swingMirror",
			"rom_path": "M540 430 Q395 360 345 195",
			"hold_x": 345.0,
			"hold_y": 195.0,
			"cop_x": 140.0,
			"cop_y": 430.0,
			"cop_w": 250.0,
			"cop_h": 145.0,
			"cop_safe_w": 192.0,
			"cop_safe_h": 92.0,
			"rep_duration": 2.5,
			"standard_speed": {
				"pull_out": { "min_speed": 0.45, "max_speed": 0.65 },
				"return_in": { "min_speed": 0.30, "max_speed": 0.43 }
			},
			"athlete": {
				"head": Vector2(595, 162),
				"shoulder": Vector2(566, 230),
				"hip": Vector2(550, 318),
				"left_foot": Vector2(454, 444),
				"right_foot": Vector2(622, 438),
				"handle": Vector2(540, 430)
			}
		},
		"press": {
			"name": "SINGLE-ARM INCLINE CHEST PRESS",
			"pose": "pressMirror",
			"rom_path": "M430 405 L330 145",
			"hold_x": 330.0,
			"hold_y": 145.0,
			"cop_x": 150.0,
			"cop_y": 430.0,
			"cop_w": 250.0,
			"cop_h": 145.0,
			"cop_safe_w": 192.0,
			"cop_safe_h": 92.0,
			"rep_duration": 7.0,
			"standard_speed": {
				"pull_out": { "min_speed": 0.13, "max_speed": 0.18 },
				"return_in": { "min_speed": 0.08, "max_speed": 0.12 }
			},
			"athlete": {
				"head": Vector2(590, 170),
				"shoulder": Vector2(560, 228),
				"hip": Vector2(548, 310),
				"left_foot": Vector2(460, 445),
				"right_foot": Vector2(622, 438),
				"handle": Vector2(430, 405)
			}
		},
		"squat": {
			"name": "SQUAT",
			"pose": "squat",
			"rom_path": "M535 440 L535 125",
			"hold_x": 535.0,
			"hold_y": 125.0,
			"cop_x": 350.0,
			"cop_y": 469.0,
			"cop_w": 308.0,
			"cop_h": 72.0,
			"cop_safe_w": 132.0,
			"cop_safe_h": 40.0,
			"rep_duration": 3.3,
			"standard_speed": null,
			"athlete": {
				"head": Vector2(330, 150),
				"shoulder": Vector2(334, 220),
				"hip": Vector2(335, 302),
				"left_foot": Vector2(284, 444),
				"right_foot": Vector2(419, 438),
				"handle": Vector2(535, 440)
			}
		},
		"highpull": {
			"name": "DEADLIFT TO HIGH PULL",
			"pose": "highpull",
			"rom_path": "M535 440 L535 125",
			"hold_x": 535.0,
			"hold_y": 125.0,
			"cop_x": 350.0,
			"cop_y": 469.0,
			"cop_w": 308.0,
			"cop_h": 72.0,
			"cop_safe_w": 132.0,
			"cop_safe_h": 40.0,
			"rep_duration": 3.3,
			"standard_speed": null,
			"athlete": {
				"head": Vector2(330, 158),
				"shoulder": Vector2(338, 226),
				"hip": Vector2(340, 318),
				"left_foot": Vector2(278, 445),
				"right_foot": Vector2(428, 438),
				"handle": Vector2(535, 440)
			}
		},
		"upright": {
			"name": "UPRIGHT PULL",
			"pose": "upright",
			"rom_path": "M535 440 L535 125",
			"hold_x": 535.0,
			"hold_y": 125.0,
			"cop_x": 350.0,
			"cop_y": 469.0,
			"cop_w": 308.0,
			"cop_h": 72.0,
			"cop_safe_w": 132.0,
			"cop_safe_h": 40.0,
			"rep_duration": 3.3,
			"standard_speed": null,
			"athlete": {
				"head": Vector2(330, 150),
				"shoulder": Vector2(338, 220),
				"hip": Vector2(338, 306),
				"left_foot": Vector2(280, 445),
				"right_foot": Vector2(424, 438),
				"handle": Vector2(535, 440)
			}
		}
	}


static func get_action(key: String) -> Dictionary:
	_ensure_loaded()
	return _actions.get(key, {})


static func get_all_keys() -> PackedStringArray:
	_ensure_loaded()
	return PackedStringArray(_actions.keys())


static func get_action_name(key: String) -> String:
	var action := get_action(key)
	return action.get("name", key.to_upper()) if not action.is_empty() else key.to_upper()
