class_name Cannon extends Area2D

signal destroyed

@export var hp: int = 1
@onready var path_follow_2d = $Path2D/PathFollow2D
@onready var animated_sprite_2d = $AnimatedSprite2D

func _process(delta):
	if path_follow_2d.progress_ratio < 1.0:
		#if animated_sprite_2d.frame == 1:
			#animated_sprite_2d.speed_scale = 0
			#animated_sprite_2d.frame = 0
		path_follow_2d.progress_ratio += delta * 0.5
	else:
		#animated_sprite_2d.speed_scale = 1
		path_follow_2d.progress_ratio = 0.0

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
