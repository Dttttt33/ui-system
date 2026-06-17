# Motion Feedback UI - Godot Integration Spec

This package implements the `9. MOTION FEEDBACK` UI component for seven motion exercises. The component is a 2D feedback overlay: athlete PNG sequence, ROM path, target speed zone, ROM marker, direction arrow, and COP panel.

## Current Scope

The current version renders seven exercises:

| Key | Exercise | Motion folder |
| --- | --- | --- |
| `row` | `Lunge Single-Arm Row` | `res://assets/motion/row` |
| `raise` | `Single-Arm Lateral Raise` | `res://assets/motion/raise` |
| `swing` | `Squat Swing` | `res://assets/motion/swing` |
| `press` | `Single-Arm Incline Chest Press` | `res://assets/motion/press` |
| `squat` | `Squat` | `res://assets/motion/squat` |
| `highpull` | `Deadlift to High Pull` | `res://assets/motion/highpull` |
| `upright` | `Upright Pull` | `res://assets/motion/upright` |

The HTML reference uses:

```js
const visibleActionKeys = ["row", "raise", "swing", "press", "squat", "highpull", "upright"];
```

## Visual Rules

- ROM full path: dashed blue `#87CEEB`.
- ROM completed progress: blue `#4A9DD9`, opacity about `0.5`.
- Covered dashed path: white, so the progress still reads as a guided path.
- Green target area: moving ROM speed window.
- ROM marker: green inside the target area, red outside the target area.
- Direction arrow: blue style matching the current button-like two-layer token treatment.
- HOLD visuals: logic preserved, currently hidden.
- Coach Ticket and fixed HUD labels are intentionally removed from this component.

## ROM Marker Logic

The ROM marker color is driven by whether `motion_rom` is inside the current green target area.

```gdscript
var in_zone := motion_rom >= zone_start and motion_rom <= zone_end
marker.set_in_zone(in_zone)
```

Color mapping:

| State | Outer color | Middle color |
| --- | --- | --- |
| Inside target zone | `#4A9B1E` | `#6EC531` |
| Outside target zone | `#C43028` | `#E8453A` |

## Standard Cable Speed Ranges

The target green zone is based on `standardCableSpeedRange` in `motion_feedback_config.json`.

| Exercise | Rep duration | Pull out speed | Return in speed |
| --- | ---: | --- | --- |
| `Single-Arm Lunge Row` | `5.0s` | `0.18-0.23 m/s` | `0.12-0.15 m/s` |
| `Single-Arm Lateral Raise` | `4.0s` | `0.28-0.38 m/s` | `0.19-0.25 m/s` |
| `Squat Swing` | `2.5s` | `0.45-0.65 m/s` | `0.30-0.43 m/s` |
| `Single-Arm Incline Chest Press` | `7.0s` | `0.13-0.18 m/s` | `0.08-0.12 m/s` |
| `Squat` | `6.0s` | `0.15-0.21 m/s` | `0.10-0.14 m/s` |
| `Deadlift to High Pull` | `6.3s` | `0.28-0.38 m/s` | `0.19-0.25 m/s` |
| `Upright Pull` | `5.2s` | `0.24-0.34 m/s` | `0.16-0.22 m/s` |

## Runtime Config

Use `motion_feedback_config.json` as the source of truth for:

- `standardCableSpeedRange`
- `actions.{key}.displayName`
- `actions.{key}.speedProfileKey`
- `actions.{key}.romPath`
- `actions.{key}.copPanel`
- `actions.{key}.athleteFrames`

Each `athleteFrames` block uses continuous normalized PNG names:

```json
{
  "dir": "res://assets/motion/raise",
  "prefix": "raise",
  "count": 147,
  "fps": 30,
  "rect": [70, 18, 410, 545]
}
```

Frame file example:

```text
res://assets/motion/raise/raise_00000.png
res://assets/motion/raise/raise_00001.png
```

## Suggested Godot Node Structure

```text
MotionFeedbackPanel (Control)
  PanelFrame (PanelContainer)
    Stage (Control, 900x580 logical design space)
      AthleteFrame (TextureRect)
      RomPathOverlay (Control)
      CopPanel (Control)
      RomMarker (Control)
      DirectionArrow (Control)
      HoldCue (Control, hidden)
```

## Preview Mode

Preview mode can use the PNG sequence frame index as the master clock. ROM marker, direction arrow, ROM progress, and target zone should all derive from the same frame progress so the UI feels driven by the athlete motion.

## Sensor Mode

In the real game, call:

```gdscript
motion_feedback.set_sensor_state(rom_progress, cable_speed_mps, cop_value)
```

Where:

- `rom_progress`: normalized ROM progress, `0.0-1.0`.
- `cable_speed_mps`: current measured cable speed in meters per second.
- `cop_value`: normalized COP value or project-specific COP coordinates.

## Handoff Notes

- `reference/reference.html` is the visual source of truth.
- `motion_feedback_config.json` is the data source of truth.
- `motion_feedback_tokens.json` contains the visual tokens.
- The four newly added exercises use source folders `02`, `05`, `06`, and `07` from `D:\DESKTOP-GAME\运动视频\motion video 0616`, normalized into package asset folders.
- `upright.offZoneDemo` is enabled in the HTML/config to demonstrate the red out-of-target ROM marker state.
