extends CanvasLayer


var booster_burst = preload("res://assets/particules/booster_burst.tres")
var booster_flames = preload("res://assets/particules/booster_flames.tres")
var cheminy_particles = preload("res://assets/particules/cheminy_particles.tres")
var hover_flames = preload("res://assets/particules/hover_flames.tres")
var poof_parry_particles = preload("res://assets/particules/poof_parry_particles.tres")
var poof_particles = preload("res://assets/particules/poof_particles.tres")
var rail_flames = preload("res://assets/particules/rail_flames.tres")
var speed_lines = preload("res://assets/particules/speed_lines.tres")
var starts_flames = preload("res://assets/particules/starts_flames.tres")
var surface_burst = preload("res://assets/particules/surface_burst.tres")
var surface_flames = preload("res://assets/particules/surface_flames.tres")

var materials = [
	booster_burst,
	booster_flames,
	cheminy_particles,
	hover_flames,
	poof_parry_particles,
	poof_particles,
	rail_flames,
	speed_lines,
	starts_flames,
	surface_burst,
	surface_flames,
]

var frames = 0
var loaded = false


func _ready():
	for material in materials:
		var particles_instance = GPUParticles2D.new()
		particles_instance.set_process_material(material)
		particles_instance.set_one_shot(true)
		particles_instance.set_modulate(Color(1,1,1,0))
		particles_instance.set_emitting(true)
		self.add_child(particles_instance)

func _physics_process(_delta):
	if frames >= 3:
		set_physics_process(false)
		loaded = true
	frames += 1
