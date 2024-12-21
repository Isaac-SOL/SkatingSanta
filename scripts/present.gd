class_name Present extends Area2D

@export var rotation_speed_bounds: Vector2 = Vector2(-10, 10)
@export var can_frag: bool = true
@export var surprise: bool = false

@export var frag: PackedScene

@onready var cadeaux_sprites = $CadeauxSprites

var speed: Vector2 = Vector2.ZERO
var rotation_speed: float = 0

func _ready() -> void:
	rotation_speed = randf_range(rotation_speed_bounds.x, rotation_speed_bounds.y)
	cadeaux_sprites.speed_scale = 0
	if surprise:
		cadeaux_sprites.play(&"surprise")
	else:
		cadeaux_sprites.frame = randi_range(0,3)
	if not can_frag:
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		set_deferred(&"monitoring", true)
		set_deferred(&"monitorable", true)

func _process(delta: float) -> void:
	position += speed * delta
	rotation += rotation_speed * delta

func _on_area_entered(area: Area2D) -> void:
	# Do not frag on houses
	if not area.get_collision_layer_value(5) and can_frag and $/root/Main.has_upgrade(&"FRAG"):  # Avoid houses
		for angle: float in [-135.0, -45.0, 45.0, 135.0]:
			call_deferred(&"spawn_frag", Vector2.UP.rotated(deg_to_rad(angle)))
	queue_free()

func spawn_frag(direction: Vector2):
	var new_present: Present = frag.instantiate()
	new_present.speed = direction * speed.length()
	new_present.surprise = surprise
	add_sibling(new_present)
	new_present.global_position = global_position + direction * 5
	new_present.scale *= 0.5

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
