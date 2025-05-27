extends Node3D

var mat: StandardMaterial3D
var sat_max: float
var sat_min: float

var left_eye: Eye
var right_eye: Eye

var sim: Simulation

var camera: Camera3D

func _ready():
	var skin: MeshInstance3D = get_node("labassets1_fbx/Main/Head/Main/Main")
	mat = skin.get_surface_override_material(0)
	skin.set_surface_override_material(0, mat)
	for path in ["labassets1_fbx/Main/Head/Ears/Main",
				"labassets1_fbx/Main/Neck/Main",
				"labassets1_fbx/Main/Arms/Hands",
				"labassets1_fbx/Main/Legs/Feet"]:
		get_node(path).set_surface_override_material(0, mat)
	sat_max = mat.albedo_color.s
	sat_min = sat_max * 3/4
	sim = get_node("../../Simulation")
	camera = get_viewport().get_camera_3d()
	
	left_eye = get_node("labassets1_fbx/Main/Head/Eyes/Left")
	right_eye = get_node("labassets1_fbx/Main/Head/Eyes/Right")
	
func _process(delta):
	set_skin_color(sim.will_health)
	if sim.will_health > 0:
		left_eye.turn_angle(left_eye.get_angle(camera.global_position))
		right_eye.turn_angle(right_eye.get_angle(camera.global_position))


func set_skin_color(saturation: float):
	mat.albedo_color.s = sat_min + saturation * (sat_max - sat_min)
	
	
