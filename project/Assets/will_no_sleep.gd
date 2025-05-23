extends Node3D

var mat: StandardMaterial3D
var sat_max: float
var sat_min: float

var eyes: MeshInstance3D

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
	
	eyes = get_node("labassets1_fbx/Main/Head/Eyes/Pupils")
	
func _process(delta):
	if mat.albedo_color.s > sat_min:
		mat.albedo_color.s -= 0.2 * (sat_max - sat_min) * delta
	
