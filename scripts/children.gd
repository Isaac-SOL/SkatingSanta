extends House
const SPEED = 200
var launched = false
@onready var vec_traj := Vector2.UP.rotated(randf_range(PI/4, PI/2))
	
func _process(delta):
	if launched:
		%VisibleOnScreenNotifier2D.global_position += vec_traj * delta * SPEED
		%Sprite.global_position += vec_traj * delta * SPEED
		%Sprite.global_rotation -= delta * 10

func _on_area_entered(area: Area2D) -> void:
	if not voided and area is Present and not area.surprise and area not in already_hit:
		already_hit.append(area)
		hp -= 1
		hit.emit(points_awarded)
		for i in range(points_awarded):
			emit_smiley(self.position)
		%AudioHappy.play()
		if hp <= 0:
			destroy()
			%AudioConfetti.play()

func destroy():
	voided = true
	%PoofParticles.emitting = true
	%Sprite.self_modulate = Color.DIM_GRAY
	launch()
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	destroyed.emit()

func launch():
	var vec_traj = Vector2.UP.rotated(randf_range(PI/4, PI/2))
	launched = true
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_interval(1)
	tween.tween_property(%Sprite, "scale", Vector2.ZERO, 0.5)
	tween.tween_callback(queue_free)
	
