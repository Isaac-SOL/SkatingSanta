class_name Util

static func decay(a, b, d: float):
	return b + (a - b) * exp(-d)

static func decayf(a: float, b: float, d: float) -> float:
	return b + (a - b) * exp(-d)

static func decayv2(a: Vector2, b: Vector2, d: float) -> Vector2:
	return b + (a - b) * exp(-d)

static func decayv3(a: Vector3, b: Vector3, d: float) -> Vector3:
	return b + (a - b) * exp(-d)

static func decayq(a: Quaternion, b: Quaternion, d: float) -> Quaternion:
	return b + (a - b) * exp(-d)

static func clamp_angle(angle: float, custom_center: float = 0) -> float:
	angle -= custom_center
	if angle > PI:
		angle = fmod(angle + PI, TAU) - PI
	elif angle < -PI:
		angle = fmod(angle - PI, TAU) + PI
	return angle + custom_center

static func rand_on_circle(radius: float) -> Vector2:
	var angle: float = randf_range(0, TAU)
	return Vector2(sin(angle), cos(angle)) * radius

static func rand_in_circle(min_radius: float, max_radius: float) -> Vector2:
	var angle: float = randf_range(0, TAU)
	var distance: float = randf_range(min_radius, max_radius)
	return Vector2(sin(angle), cos(angle)) * distance

static func rand_on_sphere(radius: float) -> Vector3:
	# Not uniform for now sorry
	var base_vector := Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
	return base_vector.normalized() * radius

static func rand_in_sphere(min_radius: float, max_radius: float) -> Vector3:
	# Not uniform for now sorry
	var base_vector := Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
	var radius := randf_range(min_radius, max_radius)
	return base_vector.normalized() * radius

static func on_mobile() -> bool:
	return OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("android") or OS.has_feature("ios")
