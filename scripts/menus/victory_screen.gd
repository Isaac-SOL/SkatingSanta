extends Control
@onready var label_presents = $MarginContainer/VBoxContainer2/HBoxContainer/VBoxContainer/Label_presents

func _ready():
	label_presents.text = "You have delivered "+ str(Global.score) + " christmas presents !"
func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/menu.tscn")

func getTimePlayedMinute(time:int):
	return str(time/60)
