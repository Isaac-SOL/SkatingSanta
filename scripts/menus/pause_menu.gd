extends Control


func _on_resume_button_pressed():
	get_tree().call_group('MainGroup', 'pauseMenu')


func _on_mainmenu_button_pressed():
	get_tree().call_group('MainGroup', 'pauseMenu')
	get_tree().change_scene_to_file("res://scenes/menus/menu.tscn")




func _on_restart_button_pressed():
	get_tree().call_group('MainGroup', 'pauseMenu')
	get_tree().change_scene_to_file("res://scenes/main.tscn")
