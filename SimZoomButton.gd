extends Button


func _ready():
	self.pressed.connect(_pressed)
	
func _pressed():
	if not is_inside_tree():
		return
	get_tree().change_scene_to_file("res://room.tscn")
	
