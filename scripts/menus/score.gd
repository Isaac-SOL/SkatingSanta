extends Control

var user_score = preload("res://scenes/menus/user_score.tscn")
var user_id : String
var client = HTTPClient.new()
var first_occurance = []
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var user_list: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer

const url_submit = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSeWSC05_PQnuKfx1l96ugKCiD9gzehk8K_KIefzziaOB7KiZw/formResponse"

const url_data = "https://opensheet.elk.sh/1zP7pLXKQPpk5JQYPx1IE4WGrINvwhgR7cFQCe59N7e4/data"
#entry.359931179 = Id
#entry.141189832 = Points
#https://opensheet.elk.sh/spreadsheet_id/tab_name

func _ready() -> void:
	update_score()
	$MarginContainer/VBoxContainer/ExitButton.grab_focus()

func set_user_id(id: String):
	user_id = id

func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/menu.tscn")

func http_submit(results, response_code, headers, body, http):
	http.queue_free()
	
func http_data(results, response_code, headers, body):
	if !results:
		first_occurance = []
		get_tree().call_group("User","queue_free")
		var json = JSON.parse_string(body.get_string_from_utf8())
		for n in json:
			if !first_occurance.has(n["Id"]):
				first_occurance.append(n["Id"])
				var user = user_score.instantiate()
				user.id = "Santa "+n["Id"]
				user.points = n["Points"]
				user_list.add_child(user)

	
func update_score():
	var http = HTTPRequest.new()
	http.request_completed.connect(http_data)
	add_child(http)
	
	var headers = ["Content-Type: application/json"]
	http.request(url_data, headers, HTTPClient.METHOD_GET)
	#if err:
		#http.queue_free()
	print("Updating score")

func add_score(user_points : String):
	var http = HTTPRequest.new()
	http.request_completed.connect(http_submit)
	#http.connect("request_completed","http_submit",[http])
	add_child(http)
	
	var user_data = client.query_string_from_dict({
		"entry.359931179": user_id,
		"entry.141189832": user_points
	})
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var err = http.request(url_submit, headers, HTTPClient.METHOD_POST, user_data)
	if err:
		http.queue_free()
	else:
		pass
		#Reset user name and point (not necessary fdor us)
	print("Adding score : Player ="+user_id+" Points = "+user_points)
