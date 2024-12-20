class_name Enemy extends Area2D

signal destroyed

@export var hp: int = 1

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
