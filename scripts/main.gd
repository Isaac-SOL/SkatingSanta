class_name Main extends Node2D

@export var speed_high: float = 0.1
@export var speed_low: float = 1.0
@export var position_bounds: Vector2 = Vector2(20, 140)
@export var house_spawn_timing: Vector2 = Vector2(1.0, 4.0)
@export var initial_time: float = 120.0
@export var max_presents: int = 5
@export var present_reload_time: float = 1.0

@export var buildings: Array[PackedScene]

var speed: float = 1.0
var next_house_spawn: float
var score: int = 0 :
	set(value):
		score = value
		%ScoreLabel.text = "Score: " + str(score)
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

func _ready() -> void:
	next_house_spawn = randf_range(house_spawn_timing.x, house_spawn_timing.y)
	hp = %Character.start_hp
	time_left = initial_time
	presents = max_presents

func _process(delta: float) -> void:
	var norm_pos: float = (%Character.position.y - position_bounds.x) / (position_bounds.y - position_bounds.x)
	speed = lerpf(speed_high, speed_low, norm_pos)
	
	%Earth.rotation -= speed * delta
	
	next_house_spawn -= speed * delta
	if next_house_spawn <= 0:
		next_house_spawn += randf_range(house_spawn_timing.x, house_spawn_timing.y)
		var new_house: House = buildings.pick_random().instantiate()
		%Earth.add_child(new_house)
		new_house.global_position = %HouseSpawnPosition.global_position
		new_house.global_rotation = %HouseSpawnPosition.global_rotation
		new_house.destroyed.connect(_on_house_destroyed)
	
	time_left -= delta
	if time_left <= 0:
		kill()
	
	if presents < max_presents:
		reload += delta
		if reload >= present_reload_time:
			reload -= present_reload_time
			presents += 1
	else:
		reload = 0

func kill():
	Engine.time_scale = 0
	%CanvasLayerGameOver.visible = true
	%Character.visible = false

func update_ammo_text():
	%AmmoLabel.text = "Presents: " + str(presents) + " (" + str(floori(reload * 100 / present_reload_time)) + "%)"

func _on_house_destroyed():
	score += 1

func _on_character_hit() -> void:
	hp -= 1
	if hp <= 0:
		kill()

func _on_character_hit_ground() -> void:
	hp = 0
	kill()

func _on_character_exited_screen() -> void:
	hp = 0
	kill()

func _on_button_retry_pressed() -> void:
	get_tree().reload_current_scene()
	Engine.time_scale = 1
