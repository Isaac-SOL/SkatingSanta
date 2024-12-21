class_name Pipe extends Area2D

signal destroyed
@onready var pipe_sprites = $pipe_sprites
@onready var collision_shape_up = $CollisionShape_up
@onready var collision_shape_down = $CollisionShape_down

@export var hp: int = 1

func _ready():
	pipe_sprites.speed_scale = 0
	pipe_sprites.frame = randi_range(0,2)
	
	match pipe_sprites.frame:
		0:
			collision_shape_up.disabled = false
			collision_shape_down.disabled = false
		1:
			collision_shape_up.disabled = true
			collision_shape_down.disabled = false
		2:
			collision_shape_down.disabled = true
			collision_shape_up.disabled = false
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Character:
		queue_free()
		destroyed.emit()
	elif area is Present and area.surprise:
		hp -= 1
		if hp == 0:
			queue_free()
			destroyed.emit()
