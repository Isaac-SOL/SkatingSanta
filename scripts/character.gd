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

@export var present_scene: PackedScene
@export var present_launch_speed: float = 10
@export var present_parry_time: float = 0.2


var vertical_speed: float = 0
@onready var main: Main = $/root/Main
var last_frame_mouse_left_pressed: bool = false
var parry_time_left: float = 0.0


func _process(delta: float) -> void:
	vertical_speed += mass * delta
	position.y += vertical_speed * delta
	rotation_degrees = angle_by_speed * vertical_speed
	
	if parry_time_left > 0.0:
		parry_time_left -= delta
	
	if main.game_state == Main.GameState.RUNNING:
		if Input.is_action_just_pressed("shoot_down") and main.presents > 0:
			main.presents -= 1
			if impulse_override_speed:
				vertical_speed = -upwards_impulse
			else:
				vertical_speed -= upwards_impulse
			var new_present: Present = present_scene.instantiate()
			main.add_child(new_present)
			new_present.global_position = global_position
			new_present.speed.y = present_launch_speed
		
		elif Input.is_action_just_pressed("shoot_up") and main.presents > 0:
			main.presents -= 1
			if impulse_override_speed:
				vertical_speed = downwards_impulse
			else:
				vertical_speed += downwards_impulse
			var new_present: Present = present_scene.instantiate()
			main.add_child(new_present)
			new_present.global_position = global_position
			new_present.speed.y = -present_launch_speed
		
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not last_frame_mouse_left_pressed and main.presents > 0:
			last_frame_mouse_left_pressed = true
			main.presents -= 1
			var dir_vector := (get_global_mouse_position() - global_position).normalized()
			var speed_mult := Vector2.DOWN.dot(dir_vector)
			speed_mult = speed_mult * upwards_impulse if speed_mult > 0 else speed_mult * downwards_impulse
			if impulse_override_speed:
				vertical_speed = -speed_mult
			else:
				vertical_speed -= speed_mult
			var new_present: Present = present_scene.instantiate()
			main.add_child(new_present)
			new_present.global_position = global_position
			new_present.speed = dir_vector * present_launch_speed
			
			if main.has_upgrade(&"PARRY"):
				parry_time_left = present_parry_time
	
	last_frame_mouse_left_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

func _on_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(1):  # World
		hit_ground.emit()
	elif area.get_collision_layer_value(5):  # Houses
		if parry_time_left > 0.0:
			parry_time_left = 0.0
			area.parry()
		else:
			hit.emit()
			vertical_speed = -hit_updards_impulse
	elif area.get_collision_layer_value(3):  # Enemies
		hit.emit()
		vertical_speed = -hit_updards_impulse

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	exited_screen.emit()
