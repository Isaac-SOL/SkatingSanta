extends Control

var max_length: float

# Called when the node enters the scene tree for the first time.
func _ready():
	max_length = %Ammo_mask.size.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_value(value):
	%Ammo_Bar.value = value
	#%Ammo_Bar.material.set("shader_parameter/mask_position", Vector2(-1./6, -1./6))
	#%Ammo_Bar.material.set("shader_parameter/mask_size", Vector2(1, 1))
	
func set_mask(kadomax):
	%Ammo_mask.size.x = max_length * kadomax / 15
	#%Ammo_Bar.material.set("shader_parameter/mask_position", Vector2(float(kadomax-5)/15 -1./6, float(kadomax-5)/15 -1./6))
