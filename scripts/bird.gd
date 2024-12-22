extends Enemy

const SPEED = 50.0

@export var frequency: float  = 1
@export var amplitude: float = 100

var going_up = true
var pos_init_y = 0.0
var base_dist: float
var base_vec: Vector2
var time: float = 0.0
var first_frame: bool = true

func _process(delta: float):
	if first_frame:
		base_dist = position.length()
		base_vec = position.normalized()
		first_frame = false
	time += delta
	var new_dist = base_dist + sin(time * frequency) * amplitude
	position = base_vec * new_dist
