class_name LoadLine extends Line2D

@export var fixed_width_curve: Curve
@export var fixed_gradient: Gradient

func set_load(t: float):
	width_curve.set_point_value(1, fixed_width_curve.sample(t))
	width_curve.bake()
	gradient.set_color(1, fixed_gradient.sample(t * 0.5))
	gradient.set_color(2, fixed_gradient.sample(t))
	set_point_position(1, -Vector2(0, 10 + 10 * t))
	set_point_position(2, -Vector2(0, 10 + 20 * t))
