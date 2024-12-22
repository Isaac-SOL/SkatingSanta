extends House
const SPEED = 200
var launch = false
var vec_traj : Vector2
func _ready():
	vec_traj = Vector2.UP.rotated(randf_range(PI/4, PI/2))
	
func _process(delta):
	if launch == true:
		%Sprite.global_position += vec_traj * delta * SPEED
		%Sprite.global_rotation -= delta * 10

func _on_area_entered(area: Area2D) -> void:
	if not voided and area is Present and not area.surprise and area not in already_hit:
		already_hit.append(area)
		hp -= 1
		hit.emit(points_awarded)
		for i in range(points_awarded):
			emit_smiley(self.position)
		#%HappyParticles.restart()
		#%HappyParticles.emitting = true
		%AudioHappy.play()
		%AudioHappyHit.play()
		if hp <= 0:
			destroy()
			%AudioConfetti.play()

func destroy():
	voided = true
	%PoofParticles.emitting = true
	%Sprite.self_modulate = Color.DIM_GRAY
	launch = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	destroyed.emit()
