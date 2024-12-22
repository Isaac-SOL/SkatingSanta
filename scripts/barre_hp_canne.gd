extends Control

@onready var canabar = %Canabar
func _ready():
	update(%Character.start_hp)
	
func update(hp : int):
	match hp:
		1:
			canabar.frame = 0
		2:
			canabar.frame = 1
		3:
			canabar.frame = 2
		4:
			canabar.frame = 3
		5:
			canabar.frame = 4
		6:
			canabar.frame = 5
		7:
			canabar.frame = 6
		8:
			canabar.frame = 7
		9:
			canabar.frame = 8
