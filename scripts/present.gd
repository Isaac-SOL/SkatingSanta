class_name Present extends Area2D

@export var rotation_speed_bounds: Vector2 = Vector2(-10, 10)
@export var can_frag: bool = true
@export var surprise: bool = false
@export var points: int = 1

@export var frag: PackedScene

@onready var cadeaux_sprites = $CadeauxSprites

var speed: Vector2 = Vector2.ZERO
var rotation_speed: float = 0
var running: bool = true
var bounces_left: int = 0
var ricochets_left: int = 0
var has_gravity: bool = false

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
	if $/root/Main.has_upgrade(&"BOUNCE"):
		bounces_left = 1
	if $/root/Main.has_upgrade(&"RICOCHET"):
		ricochets_left = 1

func _process(delta: float) -> void:
	if running:
		position += speed * delta
		rotation += rotation_speed * delta
		if has_gravity:
			speed += ($/root/Main/Earth.global_position - global_position).normalized() * delta * 100

func _on_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(5) or area.get_collision_layer_value(6): # Houses
		if ricochets_left > 0:
			ricochets_left -= 1
			speed = Vector2.UP.rotated(randf_range(-PI/4, 0)) * speed.length()
			%AudioBounce.play()
			has_gravity = true
		else:
			call_deferred("destroy", area)
	else: # World, enemies, etc
		if bounces_left > 0:
			bounces_left -= 1
			speed = Vector2.UP.rotated(randf_range(0, PI/8)) * speed.length()
			%AudioBounce.play()
			has_gravity = true
		else:
			if can_frag and $/root/Main.has_upgrade(&"FRAG"):
				for angle: float in [-135.0, -45.0, 45.0, 135.0]:
					call_deferred(&"spawn_frag", Vector2.UP.rotated(deg_to_rad(angle)))
			call_deferred("destroy", area)

func spawn_frag(direction: Vector2):
	var new_present: Present = frag.instantiate()
	new_present.speed = direction * speed.length()
	new_present.surprise = surprise
	new_present.points = points
	add_sibling(new_present)
	new_present.global_position = global_position + direction * 5
	new_present.scale = scale * 0.5

func destroy(by: Node2D):
	%AudioHit.play()
	running = false
	monitoring = false
	monitorable = false
	var glob = global_position
	get_parent().remove_child(self)
	by.add_child(self)
	global_position = glob
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", scale * 4, 0.5)
	tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(queue_free)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
