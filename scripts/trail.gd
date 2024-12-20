class_name Trail extends Line2D

const MAX_POINTS: int = 100
@onready var curve := Curve2D.new()
var running = false

func _ready() -> void:
	points.clear()

func _process(delta: float) -> void:
	if running:
		var character_position: Vector2 = get_tree().get_first_node_in_group("Character").global_position
		curve.add_point(to_local(character_position))
		if curve.get_baked_points().size() > MAX_POINTS:
			curve.remove_point(0)
		points = curve.get_baked_points()
