class_name Character extends Area2D

signal hit
signal hit_ground
signal exited_screen

@export var start_hp: int = 3
@export var mass: float = 20
@export var upwards_impulse: float = 25
@export var impulse_override_speed: bool = true

@export var present_scene: PackedScene
@export var present_launch_speed: float = 10


var vertical_speed: float = 0
@onready var main: Main = $/root/Main


func _process(delta: float) -> void:
	vertical_speed += mass * delta
	position.y += vertical_speed * delta
	
	if Input.is_action_just_pressed("shoot_down") and main.presents > 0:
		main.presents -= 1
		if impulse_override_speed:
			vertical_speed = -upwards_impulse
		else:
			vertical_speed -= upwards_impulse
		var new_present: Present = present_scene.instantiate()
		main.add_child(new_present)
		new_present.global_position = global_position
		new_present.speed = present_launch_speed
	
	elif Input.is_action_just_pressed("shoot_up") and main.presents > 0:
		main.presents -= 1
		if impulse_override_speed:
			vertical_speed = upwards_impulse
		else:
			vertical_speed += upwards_impulse
		var new_present: Present = present_scene.instantiate()
		main.add_child(new_present)
		new_present.global_position = global_position
		new_present.speed = -present_launch_speed

func _on_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(1):  # World
		hit_ground.emit()
	elif area.get_collision_layer_value(3):  # Enemies
		hit.emit()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	exited_screen.emit()
