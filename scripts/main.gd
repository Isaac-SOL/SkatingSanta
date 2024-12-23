class_name Main extends Node2D

signal time_finished

enum GameState { RUNNING, PAUSED, END_GAME, WAITING_UPGRADE }

@export var speed_high: float = 0.1
@export var speed_low: float = 1.0
@export var position_bounds: Vector2 = Vector2(20, 140)
@export var speed_power: float = 2.0
@export var house_spawn_timing: Vector2 = Vector2(1.0, 4.0)
@export var children_spawn_timing: Vector2 = Vector2(1.0, 2.0)
@export var satellite_spawn_timing: Vector2 = Vector2(2.0, 10.0)
@export var pipe_spawn_timing: Vector2 = Vector2(1.0, 2.0)
@export var alien_spawn_timing: Vector2 = Vector2(1.0, 6.0)
@export var canne_spawn_timing: Vector2 = Vector2(1.0, 6.0)
@export var cannon_spawn_timing: Vector2 = Vector2(1.0, 6.0)
@export var initial_time: float = 180.0
@export var max_presents: int = 5
@export var present_reload_time: float = 1.0
@export var dash_reload_time: float = 5.0
@export var dash_speed: float = 10
@export var dash_falloff: float = 1
@export var base_level_need: int = 10
@export var level_mult: float = 1.5
@export var top_kill: float = -75

@export var buildings: Array[PackedScene]
@export var satellites: Array[PackedScene]
@export var pipes: Array[PackedScene]
@export var aliens: Array[PackedScene]
@export var cannons: Array[PackedScene]
@export var childrens: Array[PackedScene]
@export var cannes: Array[PackedScene]

@export var line_scene: PackedScene

@export var upgrades: Array[Upgrade]
@export var repeatable_upgrades: Array[RepeatableUpgrade]
@export var double_upgrade_button_scene: PackedScene


@export var picked_upgrades: Array[StringName] = []

var pause = false
var in_game_pause = false
var game_state: GameState = GameState.RUNNING
var speed: float = 1.0
var next_house_spawn: float
var next_satellite_spawn: float
var next_pipe_spawn: float
var next_alien_spawn: float
var next_cannon_spawn: float
var next_canne_spawn: float
var next_children_spawn: float
var speed_bonus: float = 1.0
var dash_additional_speed: float = 0.0
var level: int = 1
@onready var curr_level_need: int = base_level_need
var camera_target_y: float = 0.0
var time_semicolon: String = ":"

var score: int = 0 :
	set(value):
		score = value
		%ScoreLabel.text = "Happy Kids: " + str(score) + " / " + str(curr_level_need)
		%LevelProgressBar.value = score
var hp: int = 3 :
	set(value):
		hp = mini(value, 9)
		%HPLabel.text = "HP: " + str(hp)
		%HP.update(hp)
var time_left: float = 120 :
	set(value):
		time_left = value
		update_time_text()
var presents: int = 5 :
	set(value):
		presents = value
		update_ammo_barr()
var reload: float = 0 :
	set(value):
		reload = value
		update_ammo_barr()
var dash_reload: float = 0.0 :
	set(value):
		dash_reload = value
		%DashLabel.text = "Dash: " + ("READY" if dash_reload <= 0 else str(100 - floori(dash_reload * 100 / dash_reload_time)) + "%")

func _ready() -> void:
	%PauseMenu.hide()
	next_house_spawn = randf_range(house_spawn_timing.x, house_spawn_timing.y)
	next_satellite_spawn = randf_range(satellite_spawn_timing.x, satellite_spawn_timing.y)
	next_pipe_spawn = randf_range(pipe_spawn_timing.x, pipe_spawn_timing.y)
	next_alien_spawn = randf_range(alien_spawn_timing.x, alien_spawn_timing.y)
	next_cannon_spawn = randf_range(cannon_spawn_timing.x, cannon_spawn_timing.y)
	next_canne_spawn = randf_range(cannon_spawn_timing.x, cannon_spawn_timing.y)
	hp = %Character.start_hp
	time_left = initial_time
	presents = max_presents
	%HP.update(hp)
	update_max_ammo_barr()

func _process(delta: float) -> void:
	
	
	# Pause menus
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
		
		
	var norm_pos: float = (%Character.position.y - position_bounds.x) / (position_bounds.y - position_bounds.x)
	norm_pos = pow(clamp(norm_pos, 0, 1), speed_power)
	speed = lerpf(speed_high, speed_low, pow(norm_pos, speed_power))
	var bgm_speed = speed * speed_bonus
	speed += dash_additional_speed
	speed *= speed_bonus
	
	# Wind volume and pitch
	var norm_speed_wind_db = clampf((speed - 0.1) / 0.2, 0, 1)
	%WindAudio.volume_db = lerpf(-40, -5, norm_speed_wind_db)
	var norm_speed_wind_pitch = clampf((speed - 0.25) / 0.1, 0, 1)
	%WindAudio.pitch_scale = lerpf(1, 1.5, norm_speed_wind_pitch)
	
	# Rotation parallax
	%Earth.rotation -= speed * delta
	%EarthSprite.rotation -= speed * delta
	%TreesSprite.rotation -= speed * delta
	%StarsSprite1.rotation -= speed * delta * 0.05
	%StarsSprite2.rotation -= speed * delta * 0.1
	%CloudSprite2.rotation -= speed * delta * 0.5
	%CloudSprite1.rotation -= speed * delta * 0.6
	%MoonSprite.rotation -= speed * delta * 0.4
	
	# Speed lines
	var norm_speed = clampf((speed - 0.25) / 0.15, 0, 1)
	%SpeedLines.modulate = Color(1, 1, 1, norm_speed)
	
	# BGM pitch
	var norm_speed_bgm = clampf((bgm_speed - 0.12) / 0.5, 0, 1)
	%BGM.pitch_scale = lerpf(1, 1.1, norm_speed_bgm)
	
	# Move camera
	var cam_target := clampf(%Character.position.y - 50, -75, 0)
	%CameraRot.position.y = Util.decayf(%CameraRot.position.y, cam_target, 8 * delta)
	
	if level >= 1:
		process_spawn_houses(delta)
		process_spawn_satellites(delta)
		process_spawn_canne(delta)
	if level >= 2:
		process_spawn_aliens(delta)
	if level >= 3:
		process_spawn_childrens(delta)
	if level >= 5:
		process_spawn_cannon(delta)
	if level >= 6:
		process_spawn_pipe(delta)
	
	process_present_reload(delta)
	
	process_global_timer(delta)
	#process_pause()

func start_dash():
	dash_additional_speed = dash_speed
	%Character.vertical_speed = -50
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "dash_additional_speed", 0.0, dash_falloff)
	screenshake(1, 0.5)
	if has_upgrade(&"SUPER_DASH"):
		%Character.invincibility_left = 0.5
		%Character/SantaSprite2D.modulate = Color.GREEN

func process_spawn_houses(delta: float):
	next_house_spawn -= speed * delta
	if next_house_spawn <= 0:
		next_house_spawn += randf_range(house_spawn_timing.x, house_spawn_timing.y)
		var new_house: House = buildings.pick_random().instantiate()
		%Earth.add_child(new_house)
		new_house.global_position = %HouseSpawnPosition.global_position
		new_house.global_rotation = %HouseSpawnPosition.global_rotation
		new_house.hit.connect(_on_house_destroyed)
		new_house.destroyed.connect(_on_house_destroyed_frfr)

func process_spawn_cannon(delta: float):
	next_cannon_spawn -= speed * delta * 1.3
	if next_cannon_spawn <= 0:
		next_cannon_spawn += randf_range(cannon_spawn_timing.x, cannon_spawn_timing.y)
		var new_cannon: Cannon = cannons.pick_random().instantiate()
		%Earth.add_child(new_cannon)
		new_cannon.global_position = %HouseSpawnLowerGround.global_position
		new_cannon.global_rotation = %HouseSpawnLowerGround.global_rotation
		
		
func process_spawn_canne(delta: float):
	next_canne_spawn -= speed * delta * 1.3
	if next_canne_spawn <= 0:
		next_canne_spawn += randf_range(canne_spawn_timing.x, canne_spawn_timing.y)
		var new_canne: CanneVolante = cannes.pick_random().instantiate()
		%Earth.add_child(new_canne)
		new_canne.global_position = %CanneSpawnPosition.global_position
		new_canne.global_rotation = %CanneSpawnPosition.global_rotation

func process_spawn_satellites(delta: float):
	next_satellite_spawn -= speed * delta
	if next_satellite_spawn <= 0:
		next_satellite_spawn += randf_range(satellite_spawn_timing.x, satellite_spawn_timing.y)
		var new_satellite: Enemy = satellites.pick_random().instantiate()
		%Earth.add_child(new_satellite)
		var satellite_pos: Vector2 = lerp(%SatelliteSpawnLow.global_position, %SatelliteSpawnHigh.global_position, randf())
		new_satellite.global_position = satellite_pos
		new_satellite.global_rotation = %SatelliteSpawnLow.global_rotation
		
func process_spawn_pipe(delta: float):
	next_pipe_spawn -= speed * delta * 1.5
	if next_pipe_spawn <= 0:
		next_pipe_spawn += randf_range(pipe_spawn_timing.x, pipe_spawn_timing.y)
		var new_pipe: Pipe = pipes.pick_random().instantiate()
		%Earth.add_child(new_pipe)
		var pipe_pos: Vector2 = lerp(%SatelliteSpawnLow.global_position, %SatelliteSpawnHigh.global_position, randf())
		new_pipe.global_position = pipe_pos
		new_pipe.global_rotation = %SatelliteSpawnLow.global_rotation


func process_spawn_aliens(delta: float):
	next_alien_spawn -= speed * delta
	if next_alien_spawn <= 0:
		next_alien_spawn += randf_range(alien_spawn_timing.x, alien_spawn_timing.y)
		var new_alien: House = aliens.pick_random().instantiate()
		%Earth.add_child(new_alien)
		new_alien.global_position = %AlienSpawnPosition.global_position
		new_alien.global_rotation = %AlienSpawnPosition.global_rotation
		new_alien.hit.connect(_on_house_destroyed)
		
		
func process_spawn_childrens(delta: float):
	next_children_spawn -= speed * delta * 5
	if next_children_spawn <= 0:
		next_children_spawn += randf_range(children_spawn_timing.x, children_spawn_timing.y)
		var new_children: House = childrens.pick_random().instantiate()
		%Earth.add_child(new_children)
		var children_pos: Vector2 = lerp(%ChildrenSpawn1.global_position, %ChildrenSpawn2.global_position, randf())
		new_children.global_position = children_pos
		new_children.global_rotation = %ChildrenSpawn1.global_rotation
		new_children.hit.connect(_on_house_destroyed)

func process_present_reload(delta: float):
	if presents < max_presents:
		reload += delta
		if reload >= present_reload_time:
			reload -= present_reload_time
			presents += 1
	else:
		reload = 0

func process_global_timer(delta: float):
	var prev_time_left := time_left
	time_left -= delta
	if (prev_time_left > 120 and time_left < 120) \
		or (prev_time_left > 60 and time_left < 60) \
		or (prev_time_left > 30 and time_left < 30):
			%Beep4Audio.play()
	if time_left < 5 and (floori(time_left) < floori(prev_time_left)):
		%BeepAudio.play()
	if time_left <= 0:
		time_finished.emit()
		end_game()

#func process_pause():
	#if Input.is_action_just_pressed("pause"):
		#if game_state == GameState.RUNNING:
			#game_state = GameState.PAUSED
			#Engine.time_scale = 0
		#elif game_state == GameState.PAUSED:
			#game_state = GameState.RUNNING
			#Engine.time_scale = 1

func has_upgrade(upgrade_id: StringName) -> bool:
	return upgrade_id in picked_upgrades

func start_upgrade_screen():
	if game_state == GameState.WAITING_UPGRADE:
		return
	
	game_state = GameState.WAITING_UPGRADE
	Engine.time_scale = 0
	in_game_pause = true
	
	if upgrades.is_empty():
		curr_level_need = 1000000
		return
	
	game_state = GameState.WAITING_UPGRADE
	Engine.time_scale = 0
	
	var proposed_upgrades: Array[Upgrade] = []
	for t in [Upgrade.UpgradeType.PRESENT, Upgrade.UpgradeType.SPEED, Upgrade.UpgradeType.UTILITY]:
		var valid_upgrades: Array[Upgrade] = []
		for u: Upgrade in upgrades:
			if u.type == t and u not in proposed_upgrades and u.check_dependencies(picked_upgrades):
				valid_upgrades.append(u)
		if valid_upgrades.is_empty():
			continue
		var new_upgrade: Upgrade = valid_upgrades.pick_random()
		proposed_upgrades.append(new_upgrade)
	
	var proposed_repeatable_upgrades: Array[RepeatableUpgrade] = []
	for i in range(proposed_upgrades.size()):
		var new_upgrade: RepeatableUpgrade = repeatable_upgrades.pick_random()
		while new_upgrade in proposed_repeatable_upgrades or not new_upgrade.check_dependencies(picked_upgrades):
			new_upgrade = repeatable_upgrades.pick_random()
		proposed_repeatable_upgrades.append(new_upgrade)
		var new_upgrade_button: DoubleUpgradeButton = double_upgrade_button_scene.instantiate()
		%UpgradeButtonsContainer.add_child(new_upgrade_button)
		new_upgrade_button.set_upgrades(proposed_upgrades[i], new_upgrade)
		if i == 0:
			new_upgrade_button.grab_focus()
	
	%CanvasLayerUpgrades.visible = true
	screen_click_protection()

func kill():
	Engine.time_scale = 0
	in_game_pause = true
	game_state = GameState.END_GAME
	%CanvasLayerEnd.visible = true
	screen_click_protection()
	%LabelEnd.text = "Game Over"
	%LabelEndPresents.text = "Presents delivered: " + str(score)
	%ButtonRetry.grab_focus()

func end_game():
	Engine.time_scale = 0
	in_game_pause = true
	game_state = GameState.END_GAME
	%CanvasLayerEnd.visible = true
	screen_click_protection()
	%LabelEndPresents.text = "Presents offered: " + str(score)
	%ButtonRetry.grab_focus()

func update_ammo_barr():
	%Ammo.set_value( 100 * (presents + reload / present_reload_time) )
	
func update_max_ammo_barr():
	%Ammo.set_mask(max_presents)

func update_ammo_text():
	%AmmoLabel.text = "Presents: " + str(presents) + " (" + str(floori(reload * 100 / present_reload_time)) + "%)"

func update_time_text():
	var rtime: int = initial_time - time_left + (9 * 60)
	var hrs: int = rtime / 60
	var mins: int = rtime - (60 * hrs)
	var str_mins := str(mins)
	if str_mins.length() == 1: str_mins = "0" + str_mins
	%TimeLabel.text = str(hrs) + time_semicolon + str_mins

func _on_house_destroyed(points_awarded: int):
	score += points_awarded
	if score >= curr_level_need:
		start_upgrade_screen()

func _on_house_destroyed_frfr():
	if has_upgrade(&"GROUP_BONUS"):
		score += 2
		if game_state != GameState.WAITING_UPGRADE and score >= curr_level_need:
			start_upgrade_screen()

func _on_character_hit() -> void:
	hp -= 1
	if hp <= 0:
		kill()

func _on_character_hit_ground() -> void:
	hp = 0
	%RectGround.visible = true
	kill()

func _on_character_exited_screen() -> void:
	hp = 0
	kill()

func _on_button_retry_pressed() -> void:
	get_tree().reload_current_scene()
	Engine.time_scale = 1
	in_game_pause = false

func _on_upgrade_button_pressed(upgrade_id: StringName, repeatable_id: StringName) -> void:
	if game_state != GameState.WAITING_UPGRADE:
		return
	if %CanvasLayerClickProtection.visible:
		return
	
	picked_upgrades.append(upgrade_id)
	for i in range(upgrades.size()):
		if upgrades[i].id == upgrade_id:
			upgrades.remove_at(i)
			break
	
	level += 1
	apply_new_level()
	do_upgrade_instant_effect(upgrade_id)
	do_upgrade_instant_effect(repeatable_id)
	%UpgradeAudio.play()
	%Character.invincibility_left = %Character.invincibility_time
	%Character/SantaSprite2D.modulate = Color.GREEN
	%Character.upgrade_effect()
	
	%LevelProgressBar.min_value = curr_level_need
	base_level_need *= level_mult
	curr_level_need += base_level_need
	%ScoreLabel.text = "Happy Kids: " + str(score) + " / " + str(curr_level_need)
	%LevelProgressBar.max_value = curr_level_need
	%LevelProgressBar.value = score
	
	close_upgrades_screen()

func close_upgrades_screen():
	for child: Button in %UpgradeButtonsContainer.get_children():
		child.queue_free()
	game_state = GameState.RUNNING
	Engine.time_scale = 1
	in_game_pause = false
	%CanvasLayerUpgrades.visible = false

func apply_new_level():
	house_spawn_timing *= 0.93
	satellite_spawn_timing *= 0.93
	pipe_spawn_timing *= 0.93
	alien_spawn_timing *= 0.93
	cannon_spawn_timing *= 0.93
	children_spawn_timing *= 0.93
	
	match level:
		3:
			satellite_spawn_timing /= 2
			buildings.append(preload("res://objects/bigger_house.tscn"))
		4:
			satellites.append(preload("res://objects/bird.tscn"))
		5:
			aliens.append(preload("res://objects/alien_moyen.tscn"))
		6:
			children_spawn_timing /= 2
		7:
			satellite_spawn_timing *= 2

func do_upgrade_instant_effect(upgrade_id: StringName):
	
	match upgrade_id:
		# Repeatables
		&"MORE_SPEED":
			speed_bonus *= 1.3
		&"MORE_PRESENTS":
			max_presents += 1
			present_reload_time *= 0.85
			update_max_ammo_barr()
		&"MORE_HP":
			hp += 1
		&"MORE_TIME":
			time_left += 20
		&"DODGE_RELOAD":
			%Character.dodge_reload_time *= 0.85
		
		# Non-repeatables
		&"SPEED_LOW":
			speed_low *= 1.7
		&"SPEED_HIGH":
			speed_high *= 2
		&"FAST_PRESENTS":
			%Character.present_launch_speed *= 2
		&"RAINBOW":
			%RainbowLine.running = true
			%RainbowLine.visible = true
		&"HEAVY":
			%Character.mass *= 1.5
		&"LIGHT":
			%Character.mass *= 0.6666
		&"MONEY":
			level_mult -= 0.2
		&"FLOATER":
			%Character.downwards_impulse *= 3
	
	%Character.apply_upgrade(upgrade_id)

func screen_click_protection():
	%CanvasLayerClickProtection.visible = true
	await get_tree().create_timer(0.7, true, false, true).timeout
	%CanvasLayerClickProtection.visible = false

func screenshake(amount: float, duration: float):
	%Shaker2D.shake(amount, duration)

func hitstop(duration: float):
	get_tree().paused = true
	await get_tree().create_timer(duration, true, false, true).timeout
	get_tree().paused = false

func _on_semicolon_timer_timeout() -> void:
	time_semicolon = ":" if time_semicolon == " " else " "
	update_time_text()


func pauseMenu():
	if pause:
		%PauseMenu.hide()
		if game_state == GameState.PAUSED:
			game_state = GameState.RUNNING
		if !in_game_pause:
			Engine.time_scale = 1
	else:
		%PauseMenu.show()
		if game_state == GameState.RUNNING:
			game_state = GameState.PAUSED
		Engine.time_scale = 0
	pause = !pause


func _on_button_menu_pressed():
	pauseMenu()
	get_tree().change_scene_to_file("res://scenes/menus/menu.tscn")
