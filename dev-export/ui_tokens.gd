class_name UiTokens
extends RefCounted

# =============================================================================
# Farm Ring Toss — Design Tokens (Auto-generated from tokens.json)
# Usage: var c = UiTokens.COLOR_GREEN  /  UiTokens.font_display()
# Viewport: 1920×1080, stretch_mode=canvas_items, aspect=keep
# =============================================================================

# --- Colors: Brand ---
const COLOR_GREEN := Color("#6EC531")
const COLOR_GREEN_DARK := Color("#4A9B1E")
const COLOR_GREEN_DEEP := Color("#2B5E10")
const COLOR_AMBER := Color("#F5A623")
const COLOR_AMBER_DARK := Color("#D4891A")
const COLOR_AMBER_DEEP := Color("#A06810")
const COLOR_RED := Color("#E8453A")
const COLOR_RED_DARK := Color("#C43028")
const COLOR_RED_DEEP := Color("#8B1A14")

# --- Colors: Surface ---
const COLOR_PANEL_FILL := Color("#FFF5D6")
const COLOR_PANEL_INNER := Color("#FFF9E8")
const COLOR_PANEL_BORDER := Color("#D4A84B")
const COLOR_PANEL_BORDER_DEEP := Color("#A07830")
const COLOR_CARD_ROW := Color("#F5E8C0")
const COLOR_PAGE_BG := Color("#87CEEB")
const COLOR_GRASS := Color("#6EC531")

# --- Colors: Semantic ---
const COLOR_SUCCESS := Color("#6EC531")
const COLOR_PERFECT := Color("#FFD700")
const COLOR_MISS := Color("#C4B898")
const COLOR_COMBO := Color("#E8453A")
const COLOR_WARNING := Color("#F5A623")
const COLOR_INFO := Color("#4A9DD9")
const COLOR_LOCKED := Color("#8B8B8B")

# --- Colors: Game Objects ---
const COLOR_RING_NORMAL := Color("#F5A623")
const COLOR_RING_PRECISION := Color("#4A9DD9")
const COLOR_RING_SHOCKWAVE := Color("#E8453A")
const COLOR_CHARGE_EMPTY := Color("#D4C9A8")
const COLOR_CHARGE_FILL := Color("#6EC531")
const COLOR_CHARGE_FULL := Color("#FFD700")
const COLOR_TARGET_CROP := Color("#6EC531")
const COLOR_TARGET_ANIMAL := Color("#F5C87A")
const COLOR_TARGET_GOLDEN := Color("#FFD700")

# --- Colors: Text ---
const COLOR_TEXT_DARK := Color("#4A3728")
const COLOR_TEXT_MEDIUM := Color("#6B5540")
const COLOR_TEXT_LIGHT := Color("#8B7A60")
const COLOR_TEXT_ON_GREEN := Color.WHITE
const COLOR_TEXT_ON_AMBER := Color("#4A3728")
const COLOR_TEXT_ON_RED := Color.WHITE
const COLOR_TEXT_ON_PANEL := Color("#4A3728")
const COLOR_TEXT_HUD := Color.WHITE

# --- Typography ---
const FONT_FAMILY_DISPLAY := "res://assets/fonts/LuckiestGuy-Regular.ttf"
const FONT_FAMILY_BODY := "res://assets/fonts/Fredoka-Medium.ttf"

const FONT_SIZE_HUD_SCORE := 64
const FONT_SIZE_HUD_COMBO := 52
const FONT_SIZE_HUD_LABEL := 22
const FONT_SIZE_DISPLAY_LG := 44
const FONT_SIZE_DISPLAY_MD := 32
const FONT_SIZE_TITLE := 24
const FONT_SIZE_BODY := 18
const FONT_SIZE_CAPTION := 14
const FONT_SIZE_MICRO := 11

# --- Spacing (px @ 1920×1080) ---
const SPACING_XS := 4
const SPACING_SM := 8
const SPACING_MD := 16
const SPACING_LG := 24
const SPACING_XL := 32
const SPACING_2XL := 48
const SPACING_3XL := 64

const HUD_MARGIN := 24
const HUD_GAP := 12
const PANEL_PADDING := 20
const PANEL_INNER_PADDING := 16
const SCREEN_SAFE_AREA := 40

# --- Radius ---
const RADIUS_SM := 8
const RADIUS_MD := 14
const RADIUS_LG := 20
const RADIUS_XL := 28
const RADIUS_PILL := 999
const RADIUS_PANEL := 24
const RADIUS_BUTTON := 14

# --- Depth: border + shadow (NEVER drop-shadow blur) ---
const PANEL_BORDER_WIDTH := 4
const PANEL_SHADOW_SIZE := 5
const PANEL_SHADOW_OFFSET := Vector2(0, 3)
const BUTTON_BORDER_BOTTOM := 5
const BUTTON_SHADOW_SIZE := 3
const BUTTON_SHADOW_OFFSET := Vector2(0, 2)
const BUTTON_PRESSED_OFFSET := 3
const BADGE_BORDER_WIDTH := 3
const BADGE_SHADOW_SIZE := 4
const BADGE_SHADOW_OFFSET := Vector2(0, 2)

# --- Animation Durations (seconds) ---
const ANIM_INSTANT := 0.06
const ANIM_FAST := 0.15
const ANIM_NORMAL := 0.3
const ANIM_SLOW := 0.5
const ANIM_EMPHASIS := 0.8

const ANIM_CHARGE_FILL := 1.2
const ANIM_RING_LAUNCH := 0.4
const ANIM_HIT_POP := 0.3
const ANIM_SCORE_RISE := 0.6
const ANIM_COMBO_PULSE := 0.15
const ANIM_MISS_FADE := 0.5
const ANIM_PHASE_TRANSITION := 0.8
const ANIM_STAR_SPIN := 0.4
const ANIM_BUTTON_PRESS := 0.1

# --- HUD Positions (absolute px @ 1920×1080) ---
const HUD_REP_COUNTER := Rect2(24, 12, 160, 48)
const HUD_PROGRESS_BAR := Rect2(640, 12, 640, 48)
const HUD_SCORE := Rect2(1648, 10, 260, 64)
const HUD_COMBO := Rect2(1748, 84, 160, 50)
const HUD_ACTION_CARD := Rect2(24, 300, 220, 480)
const HUD_CENTER_AREA := Rect2(660, 420, 600, 240)
const HUD_CHARGE_BAR := Rect2(800, 940, 320, 50)
const HUD_RHYTHM_BAR := Rect2(760, 980, 400, 60)

# =============================================================================
# Helper: Create standard panel StyleBox (cream + gold border + bottom shadow)
# =============================================================================
static func make_panel_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = COLOR_PANEL_FILL
	sb.border_color = COLOR_PANEL_BORDER
	sb.border_width_left = PANEL_BORDER_WIDTH
	sb.border_width_top = PANEL_BORDER_WIDTH
	sb.border_width_right = PANEL_BORDER_WIDTH
	sb.border_width_bottom = PANEL_BORDER_WIDTH
	sb.shadow_color = COLOR_PANEL_BORDER_DEEP
	sb.shadow_size = PANEL_SHADOW_SIZE
	sb.shadow_offset = PANEL_SHADOW_OFFSET
	sb.corner_radius_top_left = RADIUS_PANEL
	sb.corner_radius_top_right = RADIUS_PANEL
	sb.corner_radius_bottom_left = RADIUS_PANEL
	sb.corner_radius_bottom_right = RADIUS_PANEL
	sb.content_margin_left = PANEL_PADDING
	sb.content_margin_top = PANEL_PADDING
	sb.content_margin_right = PANEL_PADDING
	sb.content_margin_bottom = PANEL_PADDING
	return sb

# =============================================================================
# Helper: Create green button StyleBox (normal state)
# =============================================================================
static func make_button_style_normal() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = COLOR_GREEN
	sb.border_color = COLOR_GREEN_DARK
	sb.border_width_left = 0
	sb.border_width_top = 0
	sb.border_width_right = 0
	sb.border_width_bottom = BUTTON_BORDER_BOTTOM
	sb.shadow_color = COLOR_GREEN_DEEP
	sb.shadow_size = BUTTON_SHADOW_SIZE
	sb.shadow_offset = BUTTON_SHADOW_OFFSET
	sb.corner_radius_top_left = RADIUS_BUTTON
	sb.corner_radius_top_right = RADIUS_BUTTON
	sb.corner_radius_bottom_left = RADIUS_BUTTON
	sb.corner_radius_bottom_right = RADIUS_BUTTON
	sb.content_margin_left = SPACING_LG
	sb.content_margin_top = SPACING_MD
	sb.content_margin_right = SPACING_LG
	sb.content_margin_bottom = SPACING_MD
	return sb

static func make_button_style_pressed() -> StyleBoxFlat:
	var sb := make_button_style_normal()
	sb.border_width_bottom = 0
	sb.border_width_top = BUTTON_PRESSED_OFFSET
	sb.shadow_color = Color(0, 0, 0, 0)
	sb.shadow_size = 0
	sb.content_margin_top = SPACING_MD + BUTTON_PRESSED_OFFSET
	return sb

# =============================================================================
# Helper: Create pill badge StyleBox (e.g. RepCounter, HandSide)
# =============================================================================
static func make_pill_style(bg_color: Color, border_color: Color, shadow_color: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.border_color = border_color
	sb.border_width_left = BADGE_BORDER_WIDTH
	sb.border_width_top = BADGE_BORDER_WIDTH
	sb.border_width_right = BADGE_BORDER_WIDTH
	sb.border_width_bottom = BADGE_BORDER_WIDTH
	if shadow_color.a > 0:
		sb.shadow_color = shadow_color
		sb.shadow_size = BADGE_SHADOW_SIZE
		sb.shadow_offset = BADGE_SHADOW_OFFSET
	sb.corner_radius_top_left = RADIUS_PILL
	sb.corner_radius_top_right = RADIUS_PILL
	sb.corner_radius_bottom_left = RADIUS_PILL
	sb.corner_radius_bottom_right = RADIUS_PILL
	sb.content_margin_left = SPACING_MD
	sb.content_margin_top = SPACING_XS
	sb.content_margin_right = SPACING_MD
	sb.content_margin_bottom = SPACING_XS
	return sb

# =============================================================================
# Helper: Create progress track StyleBox
# =============================================================================
static func make_track_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#D4C4A0")
	sb.border_color = Color("#8B7A5A")
	sb.border_width_left = 3
	sb.border_width_top = 3
	sb.border_width_right = 3
	sb.border_width_bottom = 3
	sb.corner_radius_top_left = RADIUS_PILL
	sb.corner_radius_top_right = RADIUS_PILL
	sb.corner_radius_bottom_left = RADIUS_PILL
	sb.corner_radius_bottom_right = RADIUS_PILL
	return sb

# =============================================================================
# Helper: Bounce tween (for hit pops, combo pulses)
# =============================================================================
static func tween_bounce(tween: Tween, node: Control, duration: float = ANIM_HIT_POP) -> void:
	tween.tween_property(node, "scale", Vector2(1.3, 1.3), duration * 0.4)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "scale", Vector2.ONE, duration * 0.6)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

# =============================================================================
# Helper: Fade out and free
# =============================================================================
static func fade_out(node: Control, duration: float = ANIM_MISS_FADE) -> void:
	var tween := node.create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(node.queue_free)
