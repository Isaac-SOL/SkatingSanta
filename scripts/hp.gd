extends Control

@onready var HPbar = $/root/Main/CanvasLayer/VBoxTopLeft/HP/HP_bar
@onready var HPbar_perdu = $/root/Main/CanvasLayer/VBoxTopLeft/HP/HP_Perdu_bar
@onready var HPmap = $/root/Main/CanvasLayer/VBoxTopLeft/HP/HP_Map
@onready var main: Main = $/root/Main
#@onready var Santa = %Character

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update():
	%Canabar.frame = 9-main.hp
	%Canabar.material.set("shader_parameter/mask_position", Vector2((%Character.start_hp-4.8) * 0.10579, 1))

func update2():
	const frac = .9/10
	const ini = 3.6/10
	const ini2 = -1.6/10
	const ampli = 1.93/10
	var vie
	var viemanquente
	vie = main.hp
	viemanquente = %Character.start_hp - vie
	
	HPbar.material.set("shader_parameter/mask_position", Vector2(vie * frac - ini, vie * frac - ini))
	
	HPbar_perdu.material.set("shader_parameter/mask_position", Vector2(frac * vie - .052 * viemanquente - ini2, frac * vie - .052 * viemanquente - ini2))
	#HPbar_perdu.material.set("shader_parameter/mask_size", Vector2(1.93/10*viemanquente, 3.5/10*viemanquente))
	HPbar_perdu.material.set("shader_parameter/mask_size", Vector2(ampli*viemanquente, ampli/4*viemanquente))
