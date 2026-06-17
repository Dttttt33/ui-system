# UI Dev Guide — Farm Ring Toss

## Files in This Package

| File | What it is | How to use |
|------|-----------|------------|
| `ui_tokens.gd` | All design tokens as GDScript constants + helper functions | Add as autoload or `preload()` |
| `components.json` | 13 component specs (tree, exports, signals, style, animations) | Reference when building scenes |
| `asset_manifest.json` | Every texture asset: path, size, purpose, priority | Import checklist + loader reference |
| `theme/ui_theme.tres` | Godot Theme resource with all StyleBoxFlat presets | Apply to root or per-scene |
| `shaders/` | 7 shaders for fills, glows, gradients, shine | Materials in .tscn files reference these |
| `scripts/action_database.gd` | Action definitions (ID, name, requires_hand_switch, joint positions for collision) | Preload for session/milestone config. NOTE: `athlete` joint coords are for hit detection only — NOT rendered visually |
| `scripts/motion_feedback.gd` | MotionFeedbackPanel controller — loads athlete PNG frames + drives ROM/COP/speed overlays | Embedded inside ActionCard (replaces static illustration) |
| `scripts/cop_panel.gd` | COP overlay renderer (plate + safe zone + crosshair + trail + ping + dot) | Child of MotionFeedbackPanel |
| `scripts/rom_path_overlay.gd` | ROM path renderer (dashed line/quadratic + zone + progress bands) | Child of MotionFeedbackPanel |
| `motion_feedback_config.json` | Per-exercise config: athlete frame rects, ROM path points, COP positions, speed standards | Read by motion_feedback.gd at runtime |
| `scripts/animation_helpers.gd` | Animation utilities (score_rise, phase_slide_in, star_reveal) | Call static methods from any UI script |
| `DEV_GUIDE.md` | This file — style rules, do/don't, patterns | Read once, refer when unsure |

## Setup

```gdscript
# project.godot — register as autoload (optional, or just preload)
[autoload]
UiTokens="*res://common/ui/ui_tokens.gd"
```

Fonts required at:
- `res://common/ui/fonts/LuckiestGuy-Regular.ttf` (display/HUD)
- `res://common/ui/fonts/Fredoka-Medium.ttf` (body/UI)

## Viewport & Layout

**Target: 1920×1080** (landscape, TV/projector distance)

```cfg
window/size/viewport_width=1920
window/size/viewport_height=1080
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"
```

### HUD Layout Map (absolute px positions)

**Safe area: 40px on all edges.** All HUD elements stay inside `Rect2(40, 40, 1840, 1000)`.

```
┌─ 40px safe area ──────────────────────────────────────────────────────────┐
│                                                                           │
│              ProgressBar (960w, centered)       ScoreHUD (1.2×1.4)       │
│              x:480 y:40                         x:1496 y:40              │
│              960×54                             384×154                   │
│                                                                           │
│  ActionCard         CenterArea (below progress bar)                      │
│  x:40 y:252         x:580 y:120                                         │
│  352×576            660×500                                              │
│  fonts 1.5x         (HitResult 2x, PhaseBanner 75%,                     │
│                      MultiHit 2x, Rainbow 2x)                            │
│                                                                           │
│  GoldenCountdown: 176×176, follows pumpkin world pos (NOT fixed HUD)     │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

**Removed:** BottomCenter zone, ChargeBar, ReturnRhythmBar (no longer in use).

All positions are also available as `UiTokens.HUD_*` Rect2 constants.

### Component Size & Animation Reference

| Component | Size / Font | Position | Key Animation |
|-----------|------------|----------|---------------|
| ProgressBar | 960×54, milestones 42/33px | TopCenter (480,40) | milestone done: `tween_bounce` |
| ScoreHUD | 384×154, labels 14px, numbers 36px | TopRight (1496,40) | score change: `tween_bounce` on number |
| ActionCard | 352×576, name 30px, rep count 30px, pill 22px | Left (40,252) | card_shown: slide-in from left 300ms |
| ActionCard MotionArea | Embedded MotionFeedbackPanel (athlete + overlays), scaled 0.34x | Inside card (replaces old static IconArea) | live animation at exercise FPS |
| ActionCard blue pill | Only visible during hand-switch phase | Inside card | fade-in 200ms |
| GoldenCountdown | 176×176, ring width 18px, text 24px | Follows pumpkin in world | urgent (<1s): `shake 0.25s infinite` + ring turns red |
| HitResult | Good 56px, Perfect 84px, Miss 52px, Combo 96px | CenterArea | `tween_bounce` pop + `score_rise` 40px up + fade 600ms |
| MultiHit | Title 84px, multiplier 44px, score 32px | CenterArea | `tween_bounce` + combo-pulse |
| PhaseBanner | Text 45px, padding 28px 72px | CenterArea centered | slide-in from top 800ms + auto-fade 2s |
| FoxWarning | Fox 102px, text 61px, cream pill | Screen center | edge-glow pulse 0.7s on approach side + `tween_bounce` enter |
| BurstHint | Fullscreen edge glow, 1.5x intensity | CanvasLayer 9 | breathing pulse 1.2s ease-in-out infinite |
| SwitchHand | Text 120px, NO subtitle | CanvasLayer 15, 55% dim | instant show, holds until dismissed |
| EndPanel | 800×520, space-between, overflow:visible | CanvasLayer 20, 40% dim | stars: spin+scale 400ms staggered, panel: scale 0→1 ease-out-back |
| Rainbow | "RAINBOW!" 104px, "+BONUS" 48px | CanvasLayer 20, 15% white overlay | rainbow text: background-position shift 1.5s linear infinite |

## MotionFeedbackPanel — Athlete Rendering

The MotionFeedbackPanel shows a live exercise visualization **inside the ActionCard**. It is NOT a separate HUD element — it replaces the card's old static illustration area.

### What Gets Rendered (layers bottom to top)

1. **AthleteFrame (TextureRect)** — PNG sprite frame sequence (`textures/motion/{action}/{action}_00000.png` ... `{action}_NNNNN.png`). This is the ONLY athlete visual. No stick figures, no SVG, no procedural skeleton drawing.
2. **RomPathOverlay (Control._draw)** — Dashed path showing range of motion, with speed zone (green band) and progress (blue band) overlaid.
3. **CopPanel (Control._draw)** — Force plate rectangle with safe zone, crosshair, trail line, ping ring, and dot showing center of pressure.
4. **RomMarker (Control._draw)** — Dot on the ROM path at current progress position (green = in speed zone, red = outside).
5. **DirectionArrow (Control._draw)** — Blue arrow indicating current movement direction.

### Coordinate Space

All positions in `motion_feedback_config.json` use a **900×580 internal design space**. When embedded in ActionCard, the entire panel is uniformly scaled (~0.34x) to fit the card's width. Coordinates scale proportionally — no manual adjustment needed.

### What `action_database.gd` Athlete Joints Are For

The `athlete` dictionary (head, shoulder, hip, feet, handle) in `action_database.gd` provides joint positions for **game logic only** (hit detection, ROM anchor points). They are NOT rendered as visible stick figures or skeleton lines. Do not draw them.

### Config-Driven

Each exercise's visual layout is defined in `motion_feedback_config.json`:
- `athleteFrames.rect` — position/size of the sprite within the 900×580 space
- `athleteFrames.count/fps` — total frames and playback speed
- `romPath.type/points` — line or quadratic bezier defining the movement arc
- `copPanel.center/size/safeSize` — force plate position (always in the lower portion of the panel)

## Style Rules (DO / DON'T)

### Depth = Border + Shadow (TWO separate layers)

```
DO:  border: 4px solid BRAND_DARK  +  shadow_color: BRAND_DEEP, shadow_size: 5, shadow_offset: (0, 3)
DON'T:  Merge border+shadow into one thick border_width_bottom
DON'T:  Use blur-based box-shadow / CanvasItem shadow / light2d glow
```

This matches HTML's `border` + `box-shadow: 0 Npx 0 color`:
- **border_color** = brand dark (medium tone)
- **shadow_color** = brand deep (darkest tone, separate layer below)
- **shadow_size** = how thick the bottom "depth" bar appears
- **shadow_offset** = always `Vector2(0, 2–4)` (slightly down)

Every panel/button/badge gets depth from:
1. Colored border (brand-dark) — uniform on all 4 sides
2. `shadow_color` + `shadow_size` for the separate darker bottom bar
3. Optional inner top highlight (white @ 35-45%)

### Panels = Cream + Gold Border + Deep Shadow

```gdscript
var panel = UiTokens.make_panel_style()  # all three layers correct
```

- Fill: `#FFF5D6` (warm cream)
- Border: `#D4A84B` (4px, all sides equal)
- Shadow: `#A07830` (5px, offset (0,3))
- Radius: 24px

### Buttons = Solid Color + Bottom Border + Shadow

```gdscript
var btn_normal = UiTokens.make_button_style_normal()
var btn_pressed = UiTokens.make_button_style_pressed()
```

- Normal: border_bottom=5px DARK + shadow=3px DEEP
- Pressed: border_bottom=0, border_top=3 (squash), shadow=0 (flat)

### Text Shadows

Use `font_shadow_color` + `shadow_offset_y` for directional text shadows (NOT `font_outline`):

```
font_shadow_color = Color(brand_deep, 0.8)
shadow_offset_x = 0
shadow_offset_y = 3
```

This matches HTML's `text-shadow: 0 3px 0 rgba(...)`. Reserve `font_outline` only for thin strokes on game HUD (where it actually needs all-around visibility over busy backgrounds).

### Gradient Text

| Effect | Shader | Notes |
|--------|--------|-------|
| Static green→amber→red (top→bottom) | `vertical_gradient_text.gdshader` | EndPanel "GREAT JOB!" |
| Animated rainbow (left→right, looping) | `rainbow_text.gdshader` | RainbowFullscreen "RAINBOW!", "AMAZING!" |

### Progress Bar (Session Progress)

- Track: cream panel `#FFF5D6`, border 4px `#C8A848`, shadow 5px `#8B6A20`
- Size: **960×54** (centered top, inside 40px safe area), radius 24px
- Fill: **three-stop gradient** green `#7edb66` → yellow `#ffe064` → orange `#ff9e37`
- Fill width = `(completed_milestones / total_milestones) * track_width`
- Shader: `progress_fill.gdshader` handles fill gradient + shine

#### Dynamic Milestone Logic

Milestones are **generated at runtime** from the session's `action_plan` array.

**Input:** `action_plan: Array[{action_id: String, requires_hand_switch: bool}]`

**Generation rules:**
```
for each action in action_plan:
    add ACTION milestone (green, 42px)
    if action.requires_hand_switch AND not last segment:
        add HAND milestone (teal, 33px)
```

**`requires_hand_switch` depends on the exercise:**
- Single-arm exercises (row, raise, press, swing) → `true`
- Bilateral exercises (squat, t-bar row, upright row) → `false`

**Examples:**
| Session plan | Milestones | Count |
|---|---|---|
| 3 single-arm actions | `[A, H, A, H, A]` | 5 |
| 4 actions, 2 bilateral | `[A, H, A, A, H, A]` | 6 |
| 2 bilateral only (t-bar + squat) | `[A, A]` | 2 |

**Layout:** evenly spaced across 920px usable width (track 960 - 2×20 padding)
- Action milestone: 42×42, vertically centered (y = 6px from track top)
- Hand milestone: 33×33, vertically centered (y = 10px from track top)

**Visual states:**
- **Action done:** green `#6EC531` + white SVG ✓ checkmark
- **Hand done:** teal `#55C9C9` + white SVG ✓ checkmark
- **Action pending:** muted cream `#e8dfc8`, empty (no icon)
- **Hand pending:** light teal `#d8f0f0`, empty (no icon)
- Transition: pending → done with `tween_bounce` animation

### Animations Detail

All animations use hard/flat depth style — NO blur-based effects.

**GoldenCountdown urgent shake:**
```gdscript
# When remaining < urgent_threshold (1s):
var tween = create_tween().set_loops()
tween.tween_property(self, "rotation_degrees", 3.0, 0.0625)
tween.tween_property(self, "rotation_degrees", -3.0, 0.125)
tween.tween_property(self, "rotation_degrees", 0.0, 0.0625)
# Ring color transitions from COLOR_PERFECT (gold) to COLOR_RED
```

**Fox Warning edge glow pulse:**
```gdscript
# Directional edge glow (shader: directional_glow.gdshader)
# direction: 0=left, 1=right
# Pulsing: opacity 0.3 → 1.0, period 0.7s, ease-in-out
var tween = create_tween().set_loops()
tween.tween_property(edge_glow, "modulate:a", 1.0, 0.35).set_ease(Tween.EASE_IN_OUT)
tween.tween_property(edge_glow, "modulate:a", 0.3, 0.35).set_ease(Tween.EASE_IN_OUT)
```

**Burst Hint breathing glow:**
```gdscript
# Fullscreen edge glow (shader: edge_glow.gdshader)
# 1.5x intensity: glow_color amber @ 15%→55% opacity
# Period: 1.2s ease-in-out infinite
var tween = create_tween().set_loops()
tween.tween_method(set_glow_intensity, 0.15, 0.55, 0.6).set_ease(Tween.EASE_IN_OUT)
tween.tween_method(set_glow_intensity, 0.55, 0.15, 0.6).set_ease(Tween.EASE_IN_OUT)
```

**Rainbow text animation:**
```gdscript
# Horizontal rainbow gradient shift (shader: rainbow_text.gdshader)
# Speed: completes one full cycle in 1.5s, linear, infinite loop
# Shader uniform: uv_offset += delta / 1.5
```

### Colors — When to Use What

| Color | Use for |
|-------|---------|
| Green `#6EC531` | Primary actions, progress fill, success |
| Amber `#F5A623` | Secondary panels, warnings, ring-normal, charge cursor |
| Red `#E8453A` | Destructive/urgent, combo, ring-shockwave, fox-related |
| Gold `#FFD700` | Perfect hits, full charge, stars, golden pumpkin |
| Cream `#FFF5D6` | All panel backgrounds |
| Teal `#55C9C9` | Hand switch indicator, rest overlay |

### Text Color on Badges

| Badge color | Text color | Why |
|-------------|-----------|-----|
| Amber `#F5A623` | Dark brown `#4A3728` | Light background needs dark text |
| Green `#6EC531` | White `#FFFFFF` | Dark background needs light text |
| Red `#E8453A` | White `#FFFFFF` | Dark background needs light text |
| Gold `#FFD700` | Dark brown `#5A3A00` | Light metallic needs dark contrast |
| Cream `#FFF5D6` | Dark brown `#4A3728` | Panel text is always dark |

### Animation Patterns

```gdscript
# Pop in (for hit results, badges appearing)
UiTokens.tween_bounce(tween, node)

# Fade out and remove (for transient UI)
UiTokens.fade_out(node)

# Score rise (number floats up while fading)
AnimHelpers.score_rise(label)  # 40px up + fade over 600ms

# Phase slide in (from top + fade)
AnimHelpers.phase_slide_in(banner)  # 800ms

# Star reveal (spin + scale, staggered)
AnimHelpers.star_reveal([star1, star2, star3])  # 400ms each, 200ms stagger
```

### Stars (EndPanel, ratings)

Use rounded/fat star SVG — NOT sharp points. Import as SVGTexture or atlas.
- Gold filled: `#FFD700`
- Empty: `#D4C9A8`

## Shaders Reference

| Shader | Purpose | Key uniforms |
|--------|---------|--------------|
| `progress_fill.gdshader` | Bar fill (3-stop gradient + shine) | `progress`, `is_full`, `color_start/mid/end` |
| `rainbow_text.gdshader` | Animated horizontal rainbow text | `speed`, `scale` |
| `vertical_gradient_text.gdshader` | Static vertical gradient text | `color_top/mid/bottom`, `mid_point` |
| `edge_glow.gdshader` | Breathing edge glow (fullscreen) | `glow_color`, `intensity`, `pulse_speed`, `edge_width` |
| `directional_glow.gdshader` | One-side edge glow (fox warning) | `glow_color`, `intensity`, `direction` (0-3) |
| `button_shine.gdshader` | Top highlight on buttons/badges | `shine_height`, `shine_opacity` |

## Common Anti-Patterns

| Bad | Good | Why |
|-----|------|-----|
| `border_width_bottom = 9` (merged) | `border = 4` + `shadow_size = 5` | Two-layer depth matches HTML exactly |
| `font_outline_size = 5` for shadows | `font_shadow_color` + offset_y | Outline wraps all sides; shadow goes down only |
| `box-shadow` blur / CanvasItem shadow | `shadow_size` on StyleBoxFlat | Our style uses hard/flat shadows, no blur |
| Sharp pointed stars | Rounded/fat curved stars | Matches cartoon style |
| Thin 1px borders | 3-4px borders | Visibility at 1.5m TV distance |
| Small 12px text | Min 18px body, 22px HUD | Standing distance readability |
| Fading colors / pastels | Saturated brand colors | Cheerful + visible on projector |
| `border-radius: 50%` on badges | `border-radius: 20px` | Squircle, not circle |
| Two-color progress fill | Three-stop green→yellow→orange | Matches HTML gradient |
| Animated rainbow for victory text | Static vertical gradient shader | "GREAT JOB!" is static, not animated |

## EventBus Integration

All UI components listen to the EventBus autoload. See `components.json` → `event_bus_signals` for the full signal list. Components never call game logic directly — they emit signals upward and react to EventBus signals.

## Asset Import Checklist

1. All textures in `res://assets/textures/{category}/`
2. Import as Texture2D
3. Filter: Linear (smooth edges at scale)
4. Compression: Lossless for sprites with alpha
5. Max size per texture: 2048×2048
6. Naming: `category_name_variant.png` (see `asset_manifest.json`)
