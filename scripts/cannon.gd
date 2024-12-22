class_name Cannon extends Area2D

signal destroyed

@export var hp: int = 1
@onready var path_follow_2d = $Path2D/PathFollow2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var bullet_sprite_2d = $Path2D/PathFollow2D/bullet/BulletSprite2D

func _process(delta):
	bullet_sprite_2d.global_rotation -= delta *5
	if path_follow_2d.progress_ratio < 1.0:
		path_follow_2d.progress_ratio += delta * 0.3
	else:
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
