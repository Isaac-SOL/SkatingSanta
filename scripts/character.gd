class_name Character extends Area2D

signal hit
signal hit_ground
signal exited_screen

@export var start_hp: int = 3
@export var mass: float = 20
@export var upwards_impulse: float = 25
@export var downwards_impulse: float = 25
@export var impulse_override_speed: bool = true
@export var hit_updards_impulse: float = 25
@export var angle_by_speed: float = 1
@export var height_mass_start_y: float = 50
@export var height_mass_max: float = 20
@export var speed_animation_limit: float = 100
@export var invincibility_time: float = 1

@export var present_scene: PackedScene
@export var present_launch_speed: float = 10
@export var present_parry_time: float = 0.2
@export var present_max_load_time: float = 1.0
@export var present_max_load_mult: float = 2.0

@export var flash_scene: PackedScene


var vertical_speed: float = 0
@onready var main: Main = $/root/Main
var last_frame_mouse_left_pressed: bool = false
var parry_time_left: float = 0.0
var curr_load: float = 0.0
var last_was_loading: bool = false
var last_was_rmb: bool = false
var load_shot_direction: Vector2 = Vector2.ZERO
var invincibility_left: float = 0.0

func _process(delta: float) -> void:
	var height_mass_norm_pos = 1 - clampf(position.y / height_mass_start_y, 0, 1)
	var bonus_mass: float = height_mass_max * height_mass_norm_pos
	if main.has_upgrade(&"TOP_BOUNCE"): bonus_mass *= 3
	if main.has_upgrade(&"FLOATER"):
		vertical_speed = Util.decayf(vertical_speed, 0, delta)
	else:
		vertical_speed += (mass + bonus_mass) * delta
	position.y += vertical_speed * delta
	position.y = minf(position.y, 240)
	rotation_degrees = angle_by_speed * vertical_speed
	%RotationCancel.global_rotation = 0.0
	
	if main.speed > speed_animation_limit and %SantaSprite2D.animation != &"fast":
		%SantaSprite2D.play(&"fast")
	elif main.speed < speed_animation_limit and %SantaSprite2D.animation != &"default":
		%SantaSprite2D.play(&"default") 
	
	if parry_time_left > 0.0:
		parry_time_left -= delta
		if parry_time_left <= 0.0:
			%SantaSprite2D.modulate = Color.WHITE
	
	if invincibility_left > 0.0:
		invincibility_left -= delta
	
	if main.game_state == Main.GameState.RUNNING:
		if main.presents > 0:
			if main.has_upgrade(&"LOAD_SHOT"):
				process_shoot_loaded(delta)
			else:
				process_shoot_instant()
	
	last_frame_mouse_left_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)

func process_shoot_loaded(delta: float):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and main.has_upgrade(&"BOMB"):
		load_shot_direction = (get_global_mouse_position() - global_position).normalized()
		if not main.has_upgrade(&"OMNI_SHOT"):
			var angle: float = Vector2.UP.angle_to(load_shot_direction)
			angle = roundf(angle * 2 / PI)
			load_shot_direction = Vector2.UP.rotated(angle * PI / 2)
		increase_load(delta)
		last_was_rmb = true
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		load_shot_direction = (get_global_mouse_position() - global_position).normalized()
		if not main.has_upgrade(&"OMNI_SHOT"):
			var angle: float = Vector2.UP.angle_to(load_shot_direction)
			angle = roundf(angle * 2 / PI)
			load_shot_direction = Vector2.UP.rotated(angle * PI / 2)
		increase_load(delta)
		last_was_rmb = false
	elif Input.is_action_pressed("shoot_down"):
		load_shot_direction = Vector2.DOWN
		increase_load(delta)
		last_was_rmb = false
	elif Input.is_action_pressed("shoot_up"):
		load_shot_direction = Vector2.UP
		increase_load(delta)
		last_was_rmb = false
	elif Input.is_action_pressed("shoot_left"):
		load_shot_direction = Vector2.LEFT
		increase_load(delta)
		last_was_rmb = false
	elif Input.is_action_pressed("shoot_right"):
		load_shot_direction = Vector2.RIGHT
		increase_load(delta)
		last_was_rmb = false
	else:
		if last_was_loading:
			# Shoot
			var speed_mult := Vector2.DOWN.dot(load_shot_direction)
			speed_mult = speed_mult * upwards_impulse if speed_mult > 0 else speed_mult * downwards_impulse
			speed_mult *= 1.0 + ((present_max_load_mult - 1.0) * (curr_load / present_max_load_time))
			if impulse_override_speed:
				vertical_speed = -speed_mult
			else:
				vertical_speed -= speed_mult
			shoot_present(load_shot_direction, last_was_rmb)
			main.presents -= 1
			%LoadLine.visible = false
			curr_load = 0.0
		last_was_loading = false
		last_was_rmb = false

func increase_load(delta: float):
	curr_load += delta
	if curr_load > present_max_load_time: curr_load = present_max_load_time
	%LoadLine.set_load(curr_load / present_max_load_time)
	%LoadLine.rotation = Vector2.UP.angle_to(load_shot_direction)
	%LoadLine.visible = true
	last_was_loading = true

func process_shoot_instant():
	if Input.is_action_just_pressed("shoot_down"):
		main.presents -= 1
		if impulse_override_speed:
			vertical_speed = -upwards_impulse
		else:
			vertical_speed -= upwards_impulse
		shoot_present(Vector2.DOWN)
	
	elif Input.is_action_just_pressed("shoot_up"):
		main.presents -= 1
		if impulse_override_speed:
			vertical_speed = downwards_impulse
		else:
			vertical_speed += downwards_impulse
		shoot_present(Vector2.UP)
	
	elif Input.is_action_just_pressed("shoot_left"):
		main.presents -= 1
		shoot_present(Vector2.LEFT)
	
	elif Input.is_action_just_pressed("shoot_right"):
		main.presents -= 1
		shoot_present(Vector2.RIGHT)
	
	elif (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) \
		  or (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and main.has_upgrade(&"BOMB"))) \
		  and not last_frame_mouse_left_pressed:
		last_frame_mouse_left_pressed = true
		main.presents -= 1
		var dir_vector := (get_global_mouse_position() - global_position).normalized()
		
		if not main.has_upgrade(&"OMNI_SHOT"):
			var angle: float = Vector2.UP.angle_to(dir_vector)
			angle = roundf(angle * 2 / PI)
			dir_vector = Vector2.UP.rotated(angle * PI / 2)
		
		var speed_mult := Vector2.DOWN.dot(dir_vector)
		speed_mult = speed_mult * upwards_impulse if speed_mult > 0 else speed_mult * downwards_impulse
		if impulse_override_speed:
			vertical_speed = -speed_mult
		else:
			vertical_speed -= speed_mult
		shoot_present(dir_vector, Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and main.has_upgrade(&"BOMB"))

func shoot_present(dir_vector: Vector2, surprise: bool = false):
	var new_present: Present = present_scene.instantiate()
	new_present.speed = dir_vector * present_launch_speed
	new_present.surprise = surprise
	main.add_child(new_present)
	new_present.global_position = global_position
	if main.has_upgrade(&"LOAD_SHOT"):
		new_present.speed *= 1.0 + ((present_max_load_mult - 1.0) * (curr_load / present_max_load_time))
	if main.has_upgrade(&"PARRY"):
		parry_time_left = present_parry_time
		%AnimationPlayer.play("parry")
		%SantaSprite2D.modulate = Color.GREEN

func _on_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(1) and invincibility_left <= 0.0:  # World
		if main.has_upgrade(&"WORLD_BOUNCE"):
			hit.emit()
			vertical_speed = -hit_updards_impulse
			main.screenshake(1, 1)
			invincibility_left = invincibility_time
			spawn_flash_at(lerp(global_position, area.global_position, 0.025))
		else:
			hit_ground.emit()
	elif area.get_collision_layer_value(5) and not area.voided:  # Houses
		if parry_time_left > 0.0:
			parry_time_left = 0.0
			%SantaSprite2D.modulate = Color.WHITE
			area.parry()
			spawn_flash_at(lerp(global_position, area.global_position, 0.4))
			main.screenshake(1, 1)
			main.hitstop(0.05)
		elif invincibility_left <= 0.0:
			hit.emit()
			vertical_speed = -hit_updards_impulse
			spawn_flash_at(lerp(global_position, area.global_position, 0.4))
			main.screenshake(1.5, 0.7)
			invincibility_left = invincibility_time
	elif area.get_collision_layer_value(3) and invincibility_left <= 0.0:  # Enemies
		hit.emit()
		spawn_flash_at(lerp(global_position, area.global_position, 0.4))
		main.screenshake(1.5, 0.7)
		vertical_speed = -hit_updards_impulse
		invincibility_left = invincibility_time

func spawn_flash_at(glob: Vector2):
	var new_flash = flash_scene.instantiate()
	$/root/Main/Earth.add_child(new_flash)
	new_flash.scale *= 2
	new_flash.global_position = glob

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	exited_screen.emit()
