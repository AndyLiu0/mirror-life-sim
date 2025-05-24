extends Camera3D

var base_pos = self.position

func _ready():
	return
	
func _process(delta):
	var target_x = base_pos.x + 0.5 * (get_viewport().get_mouse_position().x / get_viewport().get_visible_rect().size.x - 0.5)
	var target_z = base_pos.z + 0.5 * (get_viewport().get_mouse_position().y / get_viewport().get_visible_rect().size.y - 0.5)

	if (abs(self.position.x - target_x) < 0.005): 
		self.position.x = target_x
	else:
		self.position.x += (4 * (target_x - position.x) + 1) * delta
		
	if (abs(self.position.z - target_z) < 0.005): 
		self.position.z = target_z
	else:
		self.position.z += (4 * (target_z - position.z) + 1) * delta
