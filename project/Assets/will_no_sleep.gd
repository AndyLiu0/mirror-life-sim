extends Node3D

var mat: StandardMaterial3D
var sat_max: float
var sat_min: float

var left_eye: Eye
var right_eye: Eye

var head: Node3D
var sim: Simulation
var camera: Camera3D

var targets = ["None", "Camera", "Mouse"]
var button_targets = ["Mouse", "Mouse", "Camera"]
var target = targets[0]
var left_target = Vector2.ZERO
var right_target = Vector2.ZERO

var timer = 5
const kS = PI * 0.03

var buttons_rect: Rect2

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
	left_eye.lim_right = true
	right_eye = get_node("labassets1_fbx/Main/Head/Eyes/Right")
	right_eye.lim_right = false
	head = get_node("labassets1_fbx/Main/Head")
	
	buttons_rect = (get_node("../../UI/AddButtons") as Control).get_rect()

func roll_target(targets_pool: Array):
	target = targets_pool[randf() * len(targets_pool)]

func _process(delta):
	set_skin_color(sim.will_health)
	if sim.will_health <= 0:
		return

	timer -= delta
	if timer < 0:
		if sim.will_health < 0.2:
			target = "Camera"
			timer = 3
		elif buttons_rect.has_point(get_viewport().get_mouse_position()):
			roll_target(button_targets)
			timer = randf_range(1, 2)
		else:
			roll_target(targets)
			timer = randf_range(2, 6)
		
	match target:
		"None":
			left_target = Vector2.ZERO
			right_target = Vector2.ZERO
		"Camera":
			left_target = left_eye.target_angle(camera.global_position)
			right_target = right_eye.target_angle(camera.global_position)
		"Mouse":
			var pos = camera.project_position(get_viewport().get_mouse_position(), 1)
			left_target = left_eye.target_angle(pos)
			right_target = right_eye.target_angle(pos)
	
	var head_target = Vector2(
		(max(abs(left_target.x), (right_target.x), PI/30) - PI/30)/3 * sign(left_target.x + right_target.x),
		(max(abs(left_target.y), (right_target.y), PI/30) - PI/30)/3 * sign(left_target.y + right_target.y)
	)
	var speed = delta * 2.0 * (0.1 + 1.5 * sim.will_health)
	var diff = head_target - Vector2(head.rotation.z, head.rotation.y)
	if diff.length() < kS * speed:
		head.rotation.z += diff.x
		head.rotation.y += diff.y
	else:
		head.rotation.z += (diff.x + sign(diff.x) * kS) * speed
		head.rotation.y += (diff.y + sign(diff.y) * kS) * speed
	
	diff = left_target - Vector2(left_eye.rotation.z, left_eye.rotation.y) - left_eye.angle
	if diff.length() < kS * speed:
		left_eye.turn_angle(left_eye.angle + diff)
	else:
		left_eye.turn_angle(left_eye.angle + (diff + sign(diff) * kS) * speed)
	diff = right_target - right_eye.angle
	if diff.length() < kS * speed:
		right_eye.turn_angle(right_eye.angle + diff)
	else:
		right_eye.turn_angle(right_eye.angle + (diff + sign(diff) * kS) * speed)


func set_skin_color(saturation: float):
	mat.albedo_color.s = sat_min + saturation * (sat_max - sat_min)
	
	
