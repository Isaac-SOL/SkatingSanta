class_name Character extends Area2D

signal hit
signal hit_bonus
signal hit_ground
signal exited_screen

@export var start_hp: int = 3
@export var mass: float = 20
@export var upwards_impulse: float = 25
@export var downwards_impulse: float = 25
@export var impulse_override_speed: bool = true
@export var hit_updards_impulse: float = 25
@export var angle_by_speed: float = 1
@export var height_mass_start_y: float = 50
@export var height_mass_max: float = 20
@export var speed_animation_limit: float = 100
@export var invincibility_time: float = 1
@export var dodge_reload_time: float = 20

@export var present_scene: PackedScene
@export var present_launch_speed: float = 10
@export var present_parry_time: float = 0.2
@export var present_max_load_time: float = 1.0
@export var present_max_load_mult: float = 2.0

@export var flash_scene: PackedScene
@export var smiley_scene: PackedScene


var vertical_speed: float = 0
@onready var main: Main = $/root/Main
var last_frame_mouse_left_pressed: bool = false
var parry_time_left: float = 0.0
var curr_load: float = 0.0
var last_was_loading: bool = false
var last_was_rmb: bool = false
var load_shot_direction: Vector2 = Vector2.ZERO
var invincibility_left: float = 0.0
var dodge_load: float = 0.0
var bonus_rotation: float = 0.0
var para_out: bool = false
var rpara_out: bool = false 
var default_anim := &"default"
var fast_anim := &"fast"
@onready var main_flames: GPUParticles2D = %StartFlames

func _process(delta: float) -> void:
	var height_mass_norm_pos = 1 - clampf((position.y + 75) / (height_mass_start_y + 75), 0, 1)
	var bonus_mass: float = height_mass_max * height_mass_norm_pos
	if main.has_upgrade(&"TOP_BOUNCE"): bonus_mass *= 3
	if main.has_upgrade(&"FLOATER"):
		vertical_speed = Util.decayf(vertical_speed, 0, delta)
	else:
		vertical_speed += (mass + bonus_mass) * delta
	position.y += vertical_speed * delta
	position.y = minf(position.y, 240)
	if position.y >= 240:
		vertical_speed = minf(vertical_speed, 0.0)
	rotation_degrees = angle_by_speed * vertical_speed
	rotation += bonus_rotation
	%RotationCancel.global_rotation = 0.0
	
	if main.speed > speed_animation_limit and %SantaSprite2D.animation != fast_anim:
		%SantaSprite2D.play(fast_anim)
		%HotteBGSprite.play(fast_anim)
		%VoucherSprite.play(fast_anim)
		%BombSprite.play(fast_anim)
		%HotteFGSprite.play(fast_anim)
	elif main.speed < speed_animation_limit and %SantaSprite2D.animation != default_anim:
		%SantaSprite2D.play(default_anim)
		%HotteBGSprite.play(default_anim)
		%VoucherSprite.play(default_anim)
		%BombSprite.play(default_anim)
		%HotteFGSprite.play(default_anim)
	
	process_parachute()
	process_flames_burst()
	
	if parry_time_left > 0.0:
		parry_time_left -= delta
		if parry_time_left <= 0.0:
			%SantaSprite2D.modulate = Color.WHITE
	
	if invincibility_left > 0.0:
		invincibility_left -= delta
	
	if main.game_state == Main.GameState.RUNNING:
		if main.presents > 0:
			if main.has_upgrade(&"LOAD_SHOT"):
				process_shoot_loaded(delta)
			else:
				process_shoot_instant()
		if main.has_upgrade(&"DODGE") and dodge_load > 0.0:
			dodge_load -= delta
			if dodge_load <= 0.0:
				# Dodge ready
				%GlassesSprite.visible = true
				var tween_scale := create_tween().set_trans(Tween.TRANS_QUAD)
				tween_scale.tween_property(%ShineSprite, "scale", Vector2(0.4, 0.4), 0.5).set_ease(Tween.EASE_OUT)
				tween_scale.tween_property(%ShineSprite, "scale", Vector2.ZERO, 0.5).set_ease(Tween.EASE_IN)
				%ShineSprite.rotation = 0
				var tween_rot := create_tween()
				tween_rot.tween_property(%ShineSprite, "rotation", TAU, 1);
	
	last_frame_mouse_left_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)

func process_shoot_loaded(delta: float):
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and main.has_upgrade(&"BOMB"):
		#load_shot_direction = (get_global_mouse_position() - global_position).normalized()
		#if not main.has_upgrade(&"OMNI_SHOT"):
			#var angle: float = Vector2.UP.angle_to(load_shot_direction)
			#angle = roundf(angle * 2 / PI)
			#load_shot_direction = Vector2.UP.rotated(angle * PI / 2)
		#increase_load(delta)
		#last_was_rmb = true
	#elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#load_shot_direction = (get_global_mouse_position() - global_position).normalized()
		#if not main.has_upgrade(&"OMNI_SHOT"):
			#var angle: float = Vector2.UP.angle_to(load_shot_direction)
			#angle = roundf(angle * 2 / PI)
			#load_shot_direction = Vector2.UP.rotated(angle * PI / 2)
		#increase_load(delta)
		#last_was_rmb = false
	if Input.is_action_just_pressed("shoot_left") and main.has_upgrade(&"DASH"):
		main.presents -= 1
		shoot_present(Vector2.LEFT * 3)
		main.start_dash()
		%BoosterBurst.emitting = true
		last_was_loading = false
		curr_load = 0.0
	
	if Input.is_action_pressed("shoot_down"):
		load_shot_direction = Vector2.DOWN
		increase_load(delta)
		last_was_rmb = false
	elif Input.is_action_pressed("shoot_up"):
		load_shot_direction = Vector2.UP
		increase_load(delta)
		last_was_rmb = false
	elif Input.is_action_pressed("shoot_right") and main.has_upgrade(&"BOMB"):
		load_shot_direction = Vector2.RIGHT
		increase_load(delta)
		last_was_rmb = true
	else:
		if last_was_loading:
			# Shoot
			var load_ratio := curr_load / present_max_load_time
			var speed_mult := Vector2.DOWN.dot(load_shot_direction)
			speed_mult = speed_mult * upwards_impulse if speed_mult > 0 else speed_mult * downwards_impulse
			speed_mult *= 1.0 + ((present_max_load_mult - 1.0) * load_ratio)
			if impulse_override_speed:
				vertical_speed = -speed_mult
			else:
				vertical_speed -= speed_mult
			var pts = 3 if load_ratio >= 1 else 2 if load_ratio >= 0.5 else 1
			shoot_present(load_shot_direction, last_was_rmb, pts)
			main.presents -= 1
			%LoadLine.visible = false
			curr_load = 0.0
		last_was_loading = false
		last_was_rmb = false

func increase_load(delta: float):
	curr_load += delta
	if curr_load > present_max_load_time: curr_load = present_max_load_time
	%LoadLine.set_load(curr_load / present_max_load_time)
	%LoadLine.rotation = Vector2.UP.angle_to(load_shot_direction)
	%LoadLine.visible = true
	last_was_loading = true

func process_shoot_instant():
	if Input.is_action_just_pressed("shoot_down"):
		main.presents -= 1
		if impulse_override_speed:
			vertical_speed = -upwards_impulse
		else:
			vertical_speed -= upwards_impulse
		shoot_present(Vector2.DOWN)
	
	elif Input.is_action_just_pressed("shoot_up"):
		main.presents -= 1
		if impulse_override_speed:
			vertical_speed = downwards_impulse
		else:
			vertical_speed += downwards_impulse
		shoot_present(Vector2.UP)
	
	elif Input.is_action_just_pressed("shoot_left") and main.has_upgrade(&"DASH"):
		main.presents -= 1
		shoot_present(Vector2.LEFT * 3)
		main.start_dash()
		%BoosterBurst.emitting = true
	
	elif Input.is_action_just_pressed("shoot_right") and main.has_upgrade(&"BOMB"):
		main.presents -= 1
		shoot_present(Vector2.RIGHT, true)
	
	#elif (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) \
		  #or (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and main.has_upgrade(&"BOMB"))) \
		  #and not last_frame_mouse_left_pressed:
		#last_frame_mouse_left_pressed = true
		#main.presents -= 1
		#var dir_vector := (get_global_mouse_position() - global_position).normalized()
		#
		#if not main.has_upgrade(&"OMNI_SHOT"):
			#var angle: float = Vector2.UP.angle_to(dir_vector)
			#angle = roundf(angle * 2 / PI)
			#dir_vector = Vector2.UP.rotated(angle * PI / 2)
		#
		#var speed_mult := Vector2.DOWN.dot(dir_vector)
		#speed_mult = speed_mult * upwards_impulse if speed_mult > 0 else speed_mult * downwards_impulse
		#if impulse_override_speed:
			#vertical_speed = -speed_mult
		#else:
			#vertical_speed -= speed_mult
		#shoot_present(dir_vector, Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and main.has_upgrade(&"BOMB"))

func shoot_present(dir_vector: Vector2, surprise: bool = false, points: int = 1) -> Present:
	var new_present: Present = present_scene.instantiate()
	new_present.speed = dir_vector * present_launch_speed
	new_present.surprise = surprise
	new_present.points = points
	main.add_child(new_present)
	new_present.global_position = global_position
	%ThrowAudio.play()
	if main.has_upgrade(&"LOAD_SHOT"):
		var load_ratio := curr_load / present_max_load_time
		new_present.speed *= 1.0 + ((present_max_load_mult - 1.0) * load_ratio)
		new_present.scale *= lerpf(1.0, 2.0, load_ratio)
	if main.has_upgrade(&"BLOCK"):
		parry_time_left = present_parry_time
		%AnimationPlayer.play("parry")
		%SantaSprite2D.modulate = Color.GREEN
	return new_present

func _on_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(6) and main.has_upgrade(&"MARIO"):
		main.screenshake(1.5, 0.7)
		vertical_speed = -hit_updards_impulse
		spawn_flash_at(lerp(global_position, area.global_position, 0.5))
		%WahooAudio.play()
		var rot_tween := create_tween()
		rot_tween.tween_property(self, "bonus_rotation", TAU, 0.3)
		rot_tween.tween_callback(func(): bonus_rotation = 0.0)
	elif area.get_collision_layer_value(1) and invincibility_left <= 0.0:  # World
		if main.has_upgrade(&"RAIL"):
			var flash := spawn_flash_at(lerp(global_position, area.global_position, 0.02))
			flash.scale.x *= 3
			flash.scale.y *= 0.5
			flash.global_rotation = 0
			flash.frame = 1
			%OhYeahAudio.play()
			%RailFlames.emitting = true
		elif main.has_upgrade(&"WORLD_BOUNCE"):
			get_hit_normal()
			spawn_flash_at(lerp(global_position, area.global_position, 0.02))
		else:
			hit_ground.emit()
			%OofAudio.play()
	elif (area.get_collision_layer_value(5) or area.get_collision_layer_value(6)) and not area.voided:  # Houses
		if parry_time_left > 0.0:
			parry_time_left = 0.0
			%SantaSprite2D.modulate = Color.WHITE
			area.parry()
			var flash := spawn_flash_at(lerp(global_position, area.global_position, 0.4))
			flash.scale.x *= 3
			flash.scale.y *= 0.5
			flash.global_rotation = 0
			flash.frame = 1
			main.screenshake(1, 1)
			main.hitstop(0.05)
			%ParryAudio.play()
		elif invincibility_left <= 0.0:
			get_hit_normal()
			spawn_flash_at(lerp(global_position, area.global_position, 0.4))
	elif area.get_collision_layer_value(3) and invincibility_left <= 0.0:  # Enemies
		get_hit_normal()
		spawn_flash_at(lerp(global_position, area.global_position, 0.4))
	elif area.get_collision_layer_value(9):  # Canne volante
		main.hp +=1
		%BonusAudio.play()

func _on_area_exited(area: Area2D) -> void:
	if area.get_collision_layer_value(1): # World
		%RailFlames.emitting = false

func get_hit_normal():
	invincibility_left = invincibility_time
	if dodge_load <= 0.0 and main.has_upgrade(&"DODGE"):
		%DodgeAudio.play()
		dodge_load = dodge_reload_time
		%GlassesSprite.visible = false
		emit_smiley()
	else:
		hit.emit()
		main.screenshake(1.5, 0.7)
		main.hitstop(0.05)
		vertical_speed = -hit_updards_impulse
		%HitAudio.play()

func spawn_flash_at(glob: Vector2) -> Node2D:
	var new_flash: Node2D = flash_scene.instantiate()
	$/root/Main/Earth.add_child(new_flash)
	new_flash.scale *= 2
	new_flash.global_position = glob
	return new_flash

func process_parachute():
	if global_position.y < 0 and not rpara_out:
		rpara_out = true
		parachute_anim(%ReverseParachute, true)
	elif global_position.y > 25 and rpara_out:
		rpara_out = false
		parachute_anim(%ReverseParachute, false)
	
	if global_position.y > 200 and not para_out:
		para_out = true
		parachute_anim(%Parachute, true)
	elif global_position.y < 175 and para_out:
		para_out = false
		parachute_anim(%Parachute, false)

func parachute_anim(para: Node2D, out: bool):
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(para, "scale", Vector2.ONE if out else Vector2.ZERO, 0.5)

func process_flames_burst():
	if main.has_upgrade(&"SPEED_LOW"):
		if global_position.y > 185 and not %SurfaceFlames.emitting:
			%StartFlames.emitting = false
			%BoosterFlames.emitting = false
			%HoverFlames.emitting = false
			%SurfaceFlames.emitting = true
			%SurfaceBurst.emitting = true
			main.screenshake(0.8, 0.7)
			%SurfaceStartAudio.play()
		if global_position.y < 160 and %SurfaceFlames.emitting:
			%SurfaceFlames.emitting = false
			main_flames.emitting = true

func emit_smiley():
	var new_smiley: Sprite2D = smiley_scene.instantiate()
	var exit_vec = Vector2.RIGHT.rotated(randf_range(-PI/8, PI/8))
	new_smiley.speed = exit_vec * 50
	%RotationCancel.add_child(new_smiley)
	new_smiley.position = Vector2.ZERO
	new_smiley.scale = Vector2.ONE * 0.8

func upgrade_effect():
	%BallSprite2D.scale = Vector2.ONE * 0.2
	%BallSprite2D.visible = true
	%BallSprite2D.modulate = Color.WHITE
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(%BallSprite2D, "scale", Vector2.ONE, 1)
	tween.parallel().tween_property(%BallSprite2D, "modulate", Color.TRANSPARENT, 1)
	tween.tween_callback(func (): %BallSprite2D.visible = false)

func apply_upgrade(upgrade_id: StringName):
	match upgrade_id:
		&"DASH":
			%DashSprite1.visible = true
			if not main.has_upgrade(&"FLOATER"):
				main_flames = %BoosterFlames
			if %StartFlames.emitting:
				%StartFlames.emitting = false
				main_flames.emitting = true
		&"SUPER_DASH":
			%DashSprite1.visible = false
			%DashSprite2.visible = true
		&"RAINBOW":
			%RainbowSprite.visible = true
		&"SPEED_HIGH":
			%WingsSprite.visible = true
		&"PARRY":
			%GoldSprite.visible = true
		&"SPEED_LOW":
			%SurfaceSprite.visible = true
		&"RAIL":
			%RailsSprite.visible = true
		&"FLOATER":
			%RainbowSprite.play("hover")
			main_flames = %HoverFlames
			if %StartFlames.emitting:
				%StartFlames.emitting = false
				main_flames.emitting = true
		&"WORLD_BOUNCE":
			%Parachute.visible = true
		&"TOP_BOUNCE":
			%ReverseParachute.visible = true
		&"LIGHT":
			default_anim = &"default_lean"
			fast_anim = &"fast_lean"
		&"HEAVY":
			default_anim = &"default_big"
			fast_anim = &"fast_big"
		&"BOMB":
			%HotteBGSprite.visible = true
			%HotteFGSprite.visible = true
			%BombSprite.visible = true
		&"MONEY":
			%HotteBGSprite.visible = true
			%HotteFGSprite.visible = true
			%VoucherSprite.visible = true
		&"DODGE":
			dodge_load = 0.0
			%GlassesSprite.visible = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	exited_screen.emit()
