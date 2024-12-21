class_name House extends Area2D

signal destroyed
signal hit

@export var hp: int = 1

var already_hit: Array[Area2D] = []
var voided: bool = false


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if not voided and area is Present and not area.surprise and area not in already_hit:
		already_hit.append(area)
		hp -= 1
		hit.emit()
		var guy: Node2D = %Guys.get_children().pick_random()
		guy.queue_free()
		%HappyParticles.restart()
		%HappyParticles.emitting = true
		if hp <= 0:
			destroy()

func parry():
	while hp > 0:
		hp -= 1
		hit.emit()
	for child in %Guys.get_children():
		child.queue_free()
	destroy()

func destroy():
	voided = true
	%PoofParticles.emitting = true
	%Sprite2D2.self_modulate = Color.DIM_GRAY
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	destroyed.emit()
