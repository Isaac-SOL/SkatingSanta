class_name Main extends Node2D

signal time_finished

enum GameState { RUNNING, PAUSED, END_GAME, WAITING_UPGRADE }

@export var speed_high: float = 0.1
@export var speed_low: float = 1.0
@export var position_bounds: Vector2 = Vector2(20, 140)
@export var speed_power: float = 2.0
@export var house_spawn_timing: Vector2 = Vector2(1.0, 4.0)
@export var satellite_spawn_timing: Vector2 = Vector2(2.0, 10.0)
@export var alien_spawn_timing: Vector2 = Vector2(1.0, 6.0)
@export var initial_time: float = 120.0
@export var max_presents: int = 5
@export var present_reload_time: float = 1.0
@export var dash_reload_time: float = 5.0
@export var dash_speed: float = 10
@export var dash_falloff: float = 0.5
@export var base_level_need: int = 10
@export var level_mult: float = 1.5

@export var buildings: Array[PackedScene]
@export var satellites: Array[PackedScene]
@export var aliens: Array[PackedScene]

@export var line_scene: PackedScene

@export var upgrades: Array[Upgrade]
@export var upgrade_button_scene: PackedScene
@export var repeatable_upgrades: Array[RepeatableUpgrade]
@export var repeatable_upgrade_button_scene: PackedScene

var game_state: GameState = GameState.RUNNING
var speed: float = 1.0
var next_house_spawn: float
var next_satellite_spawn: float
var next_alien_spawn: float
var speed_bonus: float = 1.0
var dash_additional_speed: float = 0.0
var level: int = 1
@onready var curr_level_need: int = base_level_need

var picked_upgrades: Array[StringName] = []

var score: int = 0 :
	set(value):
		score = value
		%ScoreLabel.text = "Happy Kids: " + str(score) + " / " + str(curr_level_need)
var hp: int = 3 :
	set(value):
		hp = value
		%HPLabel.text = "HP: " + str(hp)
var time_left: float = 120 :
	set(value):
		time_left = value
		%TimeLabel.text = str(ceili(time_left))
var presents: int = 5 :
	set(value):
		presents = value
		update_ammo_text()
var reload: float = 0 :
	set(value):
		reload = value
		update_ammo_text()
var dash_reload: float = 0.0 :
	set(value):
		dash_reload = value
		%DashLabel.text = "Dash: " + ("READY" if dash_reload <= 0 else str(100 - floori(dash_reload * 100 / dash_reload_time)) + "%")

func _ready() -> void:
	next_house_spawn = randf_range(house_spawn_timing.x, house_spawn_timing.y)
	next_satellite_spawn = randf_range(satellite_spawn_timing.x, satellite_spawn_timing.y)
	next_alien_spawn = randf_range(alien_spawn_timing.x, alien_spawn_timing.y)
	hp = %Character.start_hp
	time_left = initial_time
	presents = max_presents

func _process(delta: float) -> void:
	var norm_pos: float = (%Character.position.y - position_bounds.x) / (position_bounds.y - position_bounds.x)
	norm_pos = pow(clamp(norm_pos, 0, 1), speed_power)
	speed = lerpf(speed_high, speed_low, pow(norm_pos, speed_power))
	speed += dash_additional_speed
	speed *= speed_bonus
	
	#Rotation Parallax
	%Earth.rotation -= speed * delta
	%EarthSprite.rotation -= speed * delta
	%StarsSprite1.rotation -= speed * delta * 0.05
	%StarsSprite2.rotation -= speed * delta * 0.1
	%CloudSprite2.rotation -= speed * delta * 0.5
	%CloudSprite1.rotation -= speed * delta * 0.6
	
	# Speed lines
	var norm_speed = clampf((speed - 0.25) / 0.15, 0, 1)
	%SpeedLines.modulate = Color(1, 1, 1, norm_speed)
	
	if has_upgrade(&"DASH"):
		if dash_reload > 0:
			dash_reload -= delta
			if dash_reload < 0:
				dash_reload = 0
		if Input.is_action_just_pressed("dash") and dash_reload <= 0:
			start_dash()
			dash_reload = dash_reload_time
	
	process_spawn_houses(delta)
	process_spawn_satellites(delta)
	process_spawn_aliens(delta)
	
	process_present_reload(delta)
	
	process_global_timer(delta)
	
	process_pause()

func start_dash():
	dash_additional_speed = dash_speed
	var tween = create_tween()
	tween.tween_property(self, "dash_additional_speed", 0.0, dash_falloff)

func process_spawn_houses(delta: float):
	next_house_spawn -= speed * delta
	if next_house_spawn <= 0:
		next_house_spawn += randf_range(house_spawn_timing.x, house_spawn_timing.y)
		var new_house: House = buildings.pick_random().instantiate()
		%Earth.add_child(new_house)
		new_house.global_position = %HouseSpawnPosition.global_position
		new_house.global_rotation = %HouseSpawnPosition.global_rotation
		new_house.hit.connect(_on_house_destroyed)

func process_spawn_satellites(delta: float):
	next_satellite_spawn -= speed * delta
	if next_satellite_spawn <= 0:
		next_satellite_spawn += randf_range(satellite_spawn_timing.x, satellite_spawn_timing.y)
		var new_satellite: Enemy = satellites.pick_random().instantiate()
		%Earth.add_child(new_satellite)
		var satellite_pos: Vector2 = lerp(%SatelliteSpawnLow.global_position, %SatelliteSpawnHigh.global_position, randf())
		new_satellite.global_position = satellite_pos
		new_satellite.global_rotation = %SatelliteSpawnLow.global_rotation

func process_spawn_aliens(delta: float):
	next_alien_spawn -= speed * delta
	if next_alien_spawn <= 0:
		next_alien_spawn += randf_range(alien_spawn_timing.x, alien_spawn_timing.y)
		var new_alien: Alien = aliens.pick_random().instantiate()
		%Earth.add_child(new_alien)
		new_alien.global_position = %AlienSpawnPosition.global_position
		new_alien.global_rotation = %AlienSpawnPosition.global_rotation
		new_alien.hit.connect(_on_alien_destroyed)

func process_present_reload(delta: float):
	if presents < max_presents:
		reload += delta
		if reload >= present_reload_time:
			reload -= present_reload_time
			presents += 1
	else:
		reload = 0

func process_global_timer(delta: float):
	time_left -= delta
	if time_left <= 0:
		time_finished.emit()
		end_game()

func process_pause():
	if Input.is_action_just_pressed("pause"):
		if game_state == GameState.RUNNING:
			game_state = GameState.PAUSED
			Engine.time_scale = 0
		elif game_state == GameState.PAUSED:
			game_state = GameState.RUNNING
			Engine.time_scale = 1

func has_upgrade(upgrade_id: StringName) -> bool:
	return upgrade_id in picked_upgrades

func start_upgrade_screen():
	if upgrades.is_empty():
		curr_level_need = 1000000
		return
	base_level_need *= level_mult
	curr_level_need += base_level_need
	%ScoreLabel.text = "Happy Kids: " + str(score) + " / " + str(curr_level_need)
	
	game_state = GameState.WAITING_UPGRADE
	Engine.time_scale = 0
	
	var proposed_upgrades: Array[Upgrade] = []
	for i in range(min(3, upgrades.size())):
		var new_upgrade: Upgrade = upgrades.pick_random()
		while new_upgrade in proposed_upgrades or not new_upgrade.check_dependencies(picked_upgrades):
			new_upgrade = upgrades.pick_random()
		proposed_upgrades.append(new_upgrade)
		var new_upgrade_button: UpgradeButton = upgrade_button_scene.instantiate()
		%UpgradeButtonsContainer.add_child(new_upgrade_button)
		new_upgrade_button.set_upgrade(new_upgrade)
	
	var proposed_repeatable_upgrades: Array[RepeatableUpgrade] = []
	for i in range(min(2, repeatable_upgrades.size())):
		var new_upgrade: RepeatableUpgrade = repeatable_upgrades.pick_random()
		while new_upgrade in proposed_repeatable_upgrades or not new_upgrade.check_dependencies(picked_upgrades):
			new_upgrade = repeatable_upgrades.pick_random()
		proposed_repeatable_upgrades.append(new_upgrade)
		var new_upgrade_button: RepeatableUpgradeButton = repeatable_upgrade_button_scene.instantiate()
		%RepeatableUpgradeButtonsContainer.add_child(new_upgrade_button)
		new_upgrade_button.set_upgrade(new_upgrade)
	
	%CanvasLayerUpgrades.visible = true
	screen_click_protection()

func kill():
	Engine.time_scale = 0
	game_state = GameState.END_GAME
	%CanvasLayerGameOver.visible = true
	screen_click_protection()
	%Character.visible = false

func end_game():
	Engine.time_scale = 0
	game_state = GameState.END_GAME
	%CanvasLayerEnd.visible = true
	screen_click_protection()
	%LabelEndPresents.text = "Presents offered: " + str(score)

func update_ammo_text():
	%AmmoLabel.text = "Presents: " + str(presents) + " (" + str(floori(reload * 100 / present_reload_time)) + "%)"

func _on_house_destroyed():
	score += 1
	if score >= curr_level_need:
		start_upgrade_screen()
		
func _on_alien_destroyed():
	score += 3
	if score >= curr_level_need:
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

func _on_upgrade_button_pressed(upgrade_id: StringName) -> void:
	if game_state != GameState.WAITING_UPGRADE:
		return
	
	picked_upgrades.append(upgrade_id)
	for i in range(upgrades.size()):
		if upgrades[i].id == upgrade_id:
			upgrades.remove_at(i)
			break
	
	level += 1
	do_upgrade_instant_effect(upgrade_id)
	
	close_upgrades_screen()

func close_upgrades_screen():
	for child: Button in %UpgradeButtonsContainer.get_children():
		child.queue_free()
	for child: Button in %RepeatableUpgradeButtonsContainer.get_children():
		child.queue_free()
	game_state = GameState.RUNNING
	Engine.time_scale = 1
	%CanvasLayerUpgrades.visible = false

func do_upgrade_instant_effect(upgrade_id: StringName):
	# Repeatables
	if upgrade_id == &"MORE_SPEED":
		speed_bonus *= 1.1
	elif upgrade_id == &"MORE_PRESENTS":
		max_presents += 1
	elif upgrade_id == &"MORE_HP":
		hp += 2
		%Character.start_hp += 1
	elif upgrade_id == &"MORE_LOAD":
		present_reload_time *= 0.9
	elif upgrade_id == &"MORE_TIME":
		time_left += 20
	elif upgrade_id == &"DASH_RELOAD":
		dash_reload_time *= 0.8
	
	# Non-repeatables
	elif upgrade_id == &"SPEED_LOW":
		speed_low *= 1.7
	elif upgrade_id == &"SPEED_HIGH":
		speed_high *= 2
	elif upgrade_id == &"FAST_PRESENTS":
		%Character.present_launch_speed *= 2
	elif upgrade_id == &"RAINBOW":
		%RainbowLine.running = true
		%RainbowLine.visible = true
	elif upgrade_id == &"DASH":
		%DashLabel.visible = true
	elif upgrade_id == &"HEAVY":
		%Character.mass *= 1.5
	elif upgrade_id == &"LIGHT":
		%Character.mass *= 0.6666

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
	
