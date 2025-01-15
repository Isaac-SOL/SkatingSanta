extends Control

var id = "Name"
var points = "0"

@onready var id_label = $HBoxContainer/id
@onready var points_label = $HBoxContainer/points

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0
	var t = create_tween().set_trans(Tween.TRANS_QUAD)
	t.tween_property(self, "modulate:a", 1, 0.25)
	id_label.text = id
	points_label.text = points


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
