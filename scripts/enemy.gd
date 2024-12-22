class_name Enemy extends Area2D

signal destroyed

@export var hp: int = 1

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Character:
		destroy()
	elif area is Present and area.surprise:
		hp -= 1
		if hp == 0:
			destroy()

func destroy():
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	destroyed.emit()
	%AudioDestroyed.play()
	%Sprite.visible = false
	%DestroySprite.visible = true
	%DestroySprite.play("destroy")
	await %DestroySprite.animation_finished
	queue_free()
