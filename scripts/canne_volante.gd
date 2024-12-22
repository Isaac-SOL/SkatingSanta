class_name CanneVolante extends Area2D

signal destroyed

@export var hp: int = 1


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Character:
		destroyed.emit()
		%PoofParticles.emitting = true
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		%AnimatedSprite2D.visible = false
		await %PoofParticles.finished
		queue_free()
