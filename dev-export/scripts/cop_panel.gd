extends Control
class_name CopPanel

var cop_value: Vector2 = Vector2.ZERO

func set_cop(value: Vector2) -> void:
	cop_value = value
	queue_redraw()

