class_name Present extends Area2D

@export var rotation_speed_bounds: Vector2 = Vector2(-10, 10)

var speed: Vector2 = Vector2.ZERO
var rotation_speed: float = 0

func _ready() -> void:
	rotation_speed = randf_range(rotation_speed_bounds.x, rotation_speed_bounds.y)

func _process(delta: float) -> void:
	position += speed * delta
	rotation += rotation_speed * delta

func _on_area_entered(_area: Area2D) -> void:
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
