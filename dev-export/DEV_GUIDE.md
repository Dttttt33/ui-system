# UI Dev Guide — Farm Ring Toss

## Files in This Package

| File | What it is | How to use |
|------|-----------|------------|
| `ui_tokens.gd` | All design tokens as GDScript constants + helper functions | Add as autoload or `preload()` |
| `components.json` | 16 component specs (tree, exports, signals, style mapping) | Reference when building scenes |
| `asset_manifest.json` | Every texture asset: path, size, purpose, priority | Import checklist + loader reference |
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

## Style Rules (DO / DON'T)

### Depth = Border + Bottom Bar (NEVER drop-shadow)

```
DO:  border: 4px solid + bottom extra 4px darker
DON'T:  box-shadow / CanvasItem shadow / light2d glow for depth
```

Every panel/button/badge gets depth from:
1. Colored border (brand-dark)
2. Thicker bottom border OR offset bottom panel (brand-deep)
3. Optional inner top highlight (white @ 40-70%)

### Panels = Cream + Gold Border

```gdscript
var panel = UiTokens.make_panel_style()  # done
```

- Fill: `#FFF5D6`
- Border: `#D4A84B` (4px)
- Bottom bar: `#A07830` (extra 4px)
- Radius: 24px
- NO drop shadow, NO blur

### Buttons = Solid Color + Thick Bottom

```gdscript
var btn_normal = UiTokens.make_button_style_normal()
var btn_pressed = UiTokens.make_button_style_pressed()
```

Press state = translateY(3px) + reduce bottom border from 5px to 0.

### Badge/Icon Buttons = Radial Gradient Sphere

For circular icon buttons (64-80px), use ShaderMaterial:
- Highlight spot at top-left (38%, 28%)
- Main color → darker at bottom
- 3px border
- 7px bottom shadow bar
- Border-radius: 20px (NOT 50%)

### Progress/Charge Bars

- Track: `#D4C4A0`, 3px border `#8B7A5A`, inset shadow
- Fill: green→yellow gradient
- Full state: gold gradient
- Top shine strip: white @ 45%
- Height: 22px, pill radius

### Text

| Context | Font | Rule |
|---------|------|------|
| HUD numbers, titles, action names | Luckiest Guy | Always uppercase |
| Body, captions, descriptions | Fredoka | Sentence case |
| Over dark/busy backgrounds | Either | Add text-shadow: `0 3px 0 rgba(0,0,0,0.3)` |
| Over colored pill badges | Luckiest Guy | White, no shadow needed |

### Colors — When to Use What

| Color | Use for |
|-------|---------|
| Green `#6EC531` | Primary actions, progress fill, success, rep counter |
| Amber `#F5A623` | Secondary panels, warnings, ring-normal, charge cursor |
| Red `#E8453A` | Destructive/urgent, combo, ring-shockwave, fox-related |
| Gold `#FFD700` | Perfect hits, full charge, stars, golden pumpkin |
| Cream `#FFF5D6` | All panel backgrounds |

### Animation Patterns

```gdscript
# Pop in (for hit results, badges appearing)
UiTokens.tween_bounce(tween, node)

# Fade out and remove (for transient UI)
UiTokens.fade_out(node)

# Score rise (number floats up while fading)
var tween = create_tween()
tween.parallel().tween_property(label, "position:y", label.position.y - 40, 0.6)
tween.parallel().tween_property(label, "modulate:a", 0.0, 0.6)
```

### Stars (EndPanel, ratings)

Use rounded/fat star SVG — NOT sharp points. The star path has curved edges:
```
M32,4 C33,4 34,6 35,10 L37,18 C38,21 40,23 43,24 L51,25...
```
Import as SVGTexture or bake to atlas. Gold filled = `#FFD700`, empty = `#D4C9A8`.

## Common Anti-Patterns

| Bad | Good | Why |
|-----|------|-----|
| `box-shadow: 0 4px 8px rgba(...)` | Extra border-bottom width | Our style has NO soft shadows |
| Sharp pointed stars | Rounded/fat curved stars | Matches cartoon style |
| Drop shadow on panels | Solid bottom bar | Consistency with GUI pack ref |
| Thin 1px borders | 3-4px borders | Visibility at 1.5m TV distance |
| Small 12px text | Min 18px body, 22px HUD | Standing distance readability |
| Fading colors / pastels | Saturated brand colors | Cheerful + visible on projector |
| `border-radius: 50%` on badges | `border-radius: 20px` | Squircle, not circle |

## EventBus Integration

All UI components listen to the EventBus autoload. See `components.json` → `event_bus_signals` for the full signal list. Components never call game logic directly — they emit signals upward and react to EventBus signals.

## Asset Import Checklist

1. All textures in `res://assets/textures/{category}/`
2. Import as Texture2D
3. Filter: Linear (smooth edges at scale)
4. Compression: Lossless for sprites with alpha
5. Max size per texture: 2048×2048
6. Naming: `category_name_variant.png` (see `asset_manifest.json`)
