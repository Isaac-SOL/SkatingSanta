class_name Alien extends Area2D

signal destroyed
signal hit

@export var hp: int = 1


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Present:
		hp -= 1
		hit.emit()
		%Guys.get_children().pick_random().queue_free()
		if hp <= 0:
			queue_free()
			destroyed.emit()

func parry():
	while hp > 0:
		hp -= 1
		hit.emit()
	queue_free()
	destroyed.emit()
