class_name AnimHelpers
extends RefCounted

## Hit pop: scale up then bounce back (300ms)
static func hit_pop(node: Control, scale_peak: float = 1.3) -> Tween:
	var tween := node.create_tween()
	tween.tween_property(node, "scale", Vector2(scale_peak, scale_peak), 0.12)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "scale", Vector2.ONE, 0.18)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	return tween

## Score rise: float up 40px while fading out (600ms)
static func score_rise(node: Control, distance: float = 40.0) -> Tween:
	var tween := node.create_tween().set_parallel(true)
	tween.tween_property(node, "position:y", node.position.y - distance, 0.6)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(node, "modulate:a", 0.0, 0.6)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.chain().tween_callback(node.queue_free)
	return tween

## Miss fade: simple opacity fade out (500ms)
static func miss_fade(node: Control, duration: float = 0.5) -> Tween:
	var tween := node.create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(node.queue_free)
	return tween

## Combo pulse: quick scale throb x2 (150ms each)
static func combo_pulse(node: Control, count: int = 2) -> Tween:
	var tween := node.create_tween()
	for i in count:
		tween.tween_property(node, "scale", Vector2(1.15, 1.15), 0.075)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(node, "scale", Vector2.ONE, 0.075)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	return tween

## Phase transition: slide in from top + fade (800ms)
static func phase_slide_in(node: Control) -> Tween:
	node.modulate.a = 0.0
	node.position.y -= 60.0
	var tween := node.create_tween().set_parallel(true)
	tween.tween_property(node, "position:y", node.position.y + 60.0, 0.8)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "modulate:a", 1.0, 0.4)\
		.set_ease(Tween.EASE_OUT)
	return tween

## Phase transition out: fade + slide up (500ms)
static func phase_slide_out(node: Control) -> Tween:
	var tween := node.create_tween().set_parallel(true)
	tween.tween_property(node, "position:y", node.position.y - 40.0, 0.5)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(node, "modulate:a", 0.0, 0.5)\
		.set_ease(Tween.EASE_IN)
	return tween

## Charge bar fill (1200ms ease-out)
static func charge_fill(fill_node: ColorRect, target: float) -> Tween:
	var mat := fill_node.material as ShaderMaterial
	var tween := fill_node.create_tween()
	tween.tween_method(func(v): mat.set_shader_parameter("progress", v),
		mat.get_shader_parameter("progress"), target, 1.2)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	return tween

## Star spin: rotation 360 + scale pop (400ms per star, staggered)
static func star_reveal(stars: Array[Control]) -> Tween:
	var tween := stars[0].create_tween()
	for i in stars.size():
		var star := stars[i]
		star.scale = Vector2.ZERO
		star.rotation = -PI
		tween.tween_property(star, "scale", Vector2.ONE, 0.4)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)\
			.set_delay(i * 0.2)
		tween.parallel().tween_property(star, "rotation", 0.0, 0.4)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)\
			.set_delay(i * 0.2)
	return tween

## Button press: squash down then restore (100ms)
static func button_press(node: Control) -> Tween:
	var tween := node.create_tween()
	tween.tween_property(node, "scale", Vector2(1.0, 0.9), 0.05)
	tween.tween_property(node, "scale", Vector2.ONE, 0.05)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	return tween

## Edge glow breathing: modulate alpha oscillation
static func breathing_glow(node: ColorRect, min_alpha: float = 0.15, max_alpha: float = 0.55, period: float = 1.2) -> Tween:
	var tween := node.create_tween().set_loops()
	tween.tween_property(node, "color:a", max_alpha, period * 0.5)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "color:a", min_alpha, period * 0.5)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	return tween
