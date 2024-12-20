class_name Present extends Area2D

@export var rotation_speed_bounds: Vector2 = Vector2(-10, 10)
@export var can_frag: bool = true

@export var frag: PackedScene

var speed: Vector2 = Vector2.ZERO
var rotation_speed: float = 0

func _ready() -> void:
	rotation_speed = randf_range(rotation_speed_bounds.x, rotation_speed_bounds.y)

func _process(delta: float) -> void:
	position += speed * delta
	rotation += rotation_speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(1) and $/root/Main.has_upgrade(&"FRAG"):  # World
		var normal: Vector2 = (global_position - area.global_position).normalized()
		for angle: float in [-15.0, -5.0, 5.0, 15.0]:
			var new_present: Present = frag.instantiate()
			add_sibling(new_present)
			new_present.global_position = global_position
			new_present.scale *= 0.5
			new_present.speed = normal.rotated(angle) * speed.length()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
