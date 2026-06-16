# UI Dev Guide — Farm Ring Toss

## Files in This Package

| File | What it is | How to use |
|------|-----------|------------|
| `ui_tokens.gd` | All design tokens as GDScript constants + helper functions | Add as autoload or `preload()` |
| `components.json` | 16 component specs (tree, exports, signals, style mapping) | Reference when building scenes |
| `asset_manifest.json` | Every texture asset: path, size, purpose, priority | Import checklist + loader reference |
| `theme/ui_theme.tres` | Godot Theme resource with all StyleBoxFlat presets | Apply to root or per-scene |
| `shaders/` | 6 shaders for fills, glows, gradients, shine | Materials in .tscn files reference these |
| `DEV_GUIDE.md` | This file — style rules, do/don't, patterns | Read once, refer when unsure |

## Setup

```gdscript
# project.godot — register as autoload (optional, or just preload)
[autoload]
UiTokens="*res://common/ui/ui_tokens.gd"
```

Fonts required at:
- `res://assets/fonts/LuckiestGuy-Regular.ttf` (display/HUD)
- `res://assets/fonts/Fredoka-Medium.ttf` (body/UI)

## Viewport & Layout

**Target: 1920×1080** (landscape, TV/projector distance)

```cfg
window/size/viewport_width=1920
window/size/viewport_height=1080
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"
```

### HUD Layout Map (absolute px positions)

```
┌────────────────────────────────────────────────────────────────────────────┐
│ RepCounter        ProgressBar (640w, centered)           ScoreHUD         │
│ x:24 y:12         x:640 y:12                            x:1648 y:10      │
│ 160×48            640×48                                 260×64           │
│                                                          ComboCounter     │
│                                                          x:1748 y:84     │
│                                                          160×50          │
│                                                                           │
│ ActionCard                  CenterArea                                    │
│ x:24 y:300                  x:660 y:420                                  │
│ 220×480                     600×240                                      │
│                             (HitResult, PhaseBanner,                      │
│                              MultiHit, SwitchHand)                        │
│                                                                           │
│                          ChargeBar                                        │
│                          x:800 y:940                                     │
│                          320×50                                          │
│                          RhythmBar                                       │
│                          x:760 y:980                                     │
│                          400×60                                          │
└────────────────────────────────────────────────────────────────────────────┘
```

All positions are also available as `UiTokens.HUD_*` Rect2 constants.

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

### Progress/Charge Bars

- Track: `#D4C4A0`, 3px border `#8B7A5A`, pill radius
- Fill: **three-stop gradient** green `#7edb66` → yellow `#ffe064` → orange `#ff9e37`
- Full state: gold gradient (two-stop)
- Top shine strip: white @ 45%
- Height: 22px, pill radius
- Shader: `progress_fill.gdshader` handles all of this

### Colors — When to Use What

| Color | Use for |
|-------|---------|
| Green `#6EC531` | Primary actions, progress fill, success, rep counter |
| Amber `#F5A623` | Secondary panels, warnings, ring-normal, charge cursor |
| Red `#E8453A` | Destructive/urgent, combo, ring-shockwave, fox-related |
| Gold `#FFD700` | Perfect hits, full charge, stars, golden pumpkin |
| Cream `#FFF5D6` | All panel backgrounds |
| Teal `#55C9C9` | Hand switch indicator, rest overlay |

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
