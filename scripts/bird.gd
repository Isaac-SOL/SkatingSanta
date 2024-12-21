extends Enemy

const SPEED = 50.0
var going_up = true
var pos_init_y = 0.0

func _process(delta):
	if pos_init_y == 0.0:
		pos_init_y = self.position.y
		print("======================== pos_intit_y = "+str(pos_init_y))
	if going_up:
		if self.position.y > pos_init_y-50.0 :
			print("going up, pos_y = "+str(self.position.y))
			self.position.y -= delta * SPEED
		else:
			going_up = false
	elif !going_up:
		if self.position.y < pos_init_y+50.0:
			print("going down, pos_y = "+str(self.position.y))
			self.position.y += delta * SPEED
		else:
			going_up = true
		
		
