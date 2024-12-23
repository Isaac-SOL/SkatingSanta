class_name House extends Area2D

signal destroyed
signal hit(points_awarded: int)

@export var hp: int = 1
@export var points_awarded: int = 1
@export var smiley_scene: PackedScene

var already_hit: Array[Area2D] = []
var voided: bool = false
var blocked: bool = false


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if not voided and area is Present and not area.surprise and area not in already_hit:
		for p in area.points:
			already_hit.append(area)
			hp -= 1
			hit.emit(points_awarded)
			var guy: Node2D = %Guys.get_children().pick_random()
			guy.queue_free()
			for i in range(points_awarded):
				emit_smiley(guy.position)
			#%HappyParticles.restart()
			#%HappyParticles.emitting = true
			%AudioHappy.play()
			if hp <= 0:
				destroy()
				%AudioConfetti.play()
				break

func parry():
	if not blocked:
		blocked = true
	if $/root/Main.has_upgrade(&"PARRY"):
		if not voided:
			while hp > 0:
				hp -= 1
				hit.emit(points_awarded)
			for child: Node2D in %Guys.get_children():
				child.queue_free()
				for i in range(points_awarded):
					emit_smiley(child.position)
			%PoofParryParticles.emitting = true
			%AudioHappy.play()
			destroy()

func emit_smiley(pos: Vector2):
	var new_smiley: Sprite2D = smiley_scene.instantiate()
	var exit_vec: Vector2 = Vector2.LEFT if randf() < 0.5 else Vector2.RIGHT
	exit_vec = exit_vec.rotated(randf_range(-PI/8, PI/8))
	new_smiley.speed = exit_vec * 50
	add_child(new_smiley)
	new_smiley.position = pos

func destroy():
	voided = true
	%PoofParticles.emitting = true
	%Sprite.self_modulate = Color.DIM_GRAY
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	if $/root/Main.has_upgrade(&"GROUP_BONUS"):
		emit_smiley(Vector2.ZERO)
		emit_smiley(Vector2.ZERO)
	destroyed.emit()

func _on_wahoo_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(2) and hp > 0 and $/root/Main.has_upgrade(&"MARIO"): # Character
		if not voided:
			while hp > 0:
				hp -= 1
				hit.emit(points_awarded)
			for child: Node2D in %Guys.get_children():
				child.queue_free()
				for i in range(points_awarded):
					emit_smiley(child.position)
			%AudioHappy.play()
			%AudioConfetti.play()
			destroy()
	elif area.get_collision_layer_value(4): # Present
		_on_area_entered(area)
