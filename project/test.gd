extends MeshInstance3D

var camera: Camera3D

func _ready():
	camera = get_viewport().get_camera_3d()
	
func _process(delta):
	global_position = camera.project_position(get_viewport().get_mouse_position(), 1.2)
