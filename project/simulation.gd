class_name Simulation
extends Node3D

func _get_class():
	return "Simulation"

var health_label: Label
var immune_label: Label
var bacteria_label: Label
var mirror_label: Label
var vaccine_label: Label
var grapher: Grapher
var camera: Camera3D

var BOUNDS_RECT: Rect2
var IN_RECT: Rect2

var will_health = 1

var bacteria_limit: float = 1 ** 10

var bacteria_num: float = 0
var bacteria_level = 0
var bacteria_count = 0

var mirror_bacteria_num: float = 0
var mirror_bacteria_level = 0
var mirror_bacteria_count = 0

var immune_activation = 0
var complement_activation = 0
var vaccine_effect = 0

var vaccine_level = 0
var vaccine_count = 0

var glucose_level = 2
var glucose_count = 0

var glycerol_level = 2
var glycerol_count = 0

var c5a_level = 1
var c5a_count = 0

var immune_cell_level = 2
var immune_cell_count = 0

var timer = 0
var tick = 0

var spawns_queue = []

var data = {
	"Time": [],
	"Health": [],
	"Immune Activity": [],
	"Bacteria": [],
	"Mirror Bacteria": []
}

func _ready():
	var size = get_node("Plane").mesh.get_aabb().size
	BOUNDS_RECT = Rect2(-size.x/2, -size.z/2, size.x, size.z)
	IN_RECT = BOUNDS_RECT.grow(-3)
	Globals.BOUNDS_RECT = BOUNDS_RECT
	Globals.IN_RECT = IN_RECT
	health_label = get_node("../UI/Stats/Health/Label")	
	immune_label = get_node("../UI/Stats/Immune/Label")	
	bacteria_label = get_node("../UI/Stats/Bacteria/Label")	
	mirror_label = get_node("../UI/Stats/MirrorBacteria/Label")	
	vaccine_label = get_node("../UI/Stats/Vaccine/Label")	
	grapher = get_node("../UI/GraphUI/VLayout/GridContainer/GraphSpace")
	camera = get_node("SimCameraLayer/SimCameraViewportContainer/SimCameraViewport/SimCamera")
	update_sim()

func reset():
	for node in get_children():
		if node.get_class() in ["RigidBody3D", "CharacterBody3D"]:
			node.queue_free()
	spawns_queue = []
	
	data = {
		"Time": [],
		"Health": [],
		"Immune Activity": [],
		"Bacteria": [],
		"Mirror Bacteria": []
	}
	
	will_health = 1
	
	bacteria_num = 0
	bacteria_count = 0
	
	mirror_bacteria_num = 0
	mirror_bacteria_count = 0
	
	immune_activation = 0
	complement_activation = 0
	
	vaccine_effect = 0
	vaccine_count = 0
	
	glucose_count = 0
	glycerol_count = 0
	c5a_count = 0
	immune_cell_count = 0
	
	timer = 0
	tick = 0
	
	grapher.clear_lines()
	
	update_sim()
	

func _process(delta):
	if timer > 0.5:
		tick += 1
		update_sim()
		do_spawn_cycle()
		timer = 0
	timer += delta
	while len(spawns_queue) > 0 and spawns_queue[0][0] <= tick * 0.5 + timer:
		(spawns_queue.pop_front()[1] as Callable).call()

func calc_bacteria(num, immunity):
	return int(num + 1 * num**0.9 * (1 - (bacteria_num + mirror_bacteria_num)/bacteria_limit)**3 * (1 - immunity/3) - (num**0.8 * 5) * immunity**2 * (max(log(num), 0)**3 / (max(log(bacteria_num), 0.1)**3 + max(log(mirror_bacteria_num), 0)**3)) ** 0.5) - (num/5 if num < 5*10**2 else 0)
	
func update_sim():
	if will_health > 0:
		will_health += min(0.02, 0.1 * will_health) - 0.001 * clamp(log(bacteria_num + mirror_bacteria_num)/log(10), 0, 20)**2 + (1 - will_health) * 0.06
		will_health = clamp(will_health, 0, 1)
	var diff = 3 * 10**9 * sqrt(will_health) - bacteria_limit
	bacteria_limit += 0.2 * diff + 10**6 * sign(diff)
	bacteria_limit = clamp(bacteria_limit, 0, 1 * 10**9)
	var im_diff = -immune_activation * 0.045
	im_diff += 0.015 * clamp(log(bacteria_num + mirror_bacteria_num**vaccine_effect)/log(10), 0, 20)**0.7 - 0.01
	immune_activation += im_diff if im_diff > 0 else im_diff/2
	immune_activation = clamp(immune_activation, 0, min(sqrt(will_health/0.2), 1))
	complement_activation *= 0.92
	complement_activation += 0.2 * (1 - will_health) - 0.01
	complement_activation = min(max(complement_activation, 0.1), min(sqrt(will_health/0.4), 1))
	bacteria_num = max(0, calc_bacteria(bacteria_num, immune_activation + complement_activation * 0.3))
	mirror_bacteria_num = max(0, calc_bacteria(mirror_bacteria_num, immune_activation + complement_activation * 0.3))
	
	health_label.text = "Health\n%s%%" % int(will_health * 100)
	immune_label.text = "Immune Activity\n%s%%" % int(round(immune_activation * 100))
	if bacteria_num < 10000:
		bacteria_label.text = "Bacteria\n%s CFU" % int(bacteria_num)
	else:
		bacteria_label.text = "Bacteria\n%s e%s CFU" % [0.1 * int(10 * bacteria_num / 10**int(log(bacteria_num)/log(10))), int(log(bacteria_num)/log(10))]
	if mirror_bacteria_num < 10000:
		mirror_label.text = "Mirror Bacteria\n%s CFU" % int(mirror_bacteria_num)
	else:
		mirror_label.text = "Mirror Bacteria\n%s e%s CFU" % [0.1 * int(10 * mirror_bacteria_num / 10**int(log(mirror_bacteria_num)/log(10))), int(log(mirror_bacteria_num)/log(10))]
	vaccine_label.text = "Vaccine\n%s%%" % round(vaccine_effect * 100)
	
	bacteria_level = max(0, int(1.2 * max(0, log(bacteria_num))/log(10)) - 3)
	mirror_bacteria_level = max(0, int(1.2 * max(0, log(mirror_bacteria_num))/log(10)) - 3)
	immune_cell_level = (int(immune_activation * 4) + 1) if will_health > 0 else 0
	glucose_level = round(2 * min(sqrt(will_health) * 2, 1))
	glycerol_level = round(2 * min(sqrt(will_health) * 2, 1))
	vaccine_level = ceil(7 * vaccine_effect)
	c5a_level = ceil(complement_activation * 3)
	
	data["Time"].append(tick*0.5)
	data["Health"].append(will_health * 100)
	data["Immune Activity"].append(immune_activation * 100)
	data["Bacteria"].append(max(log(bacteria_num)/log(10), 0))
	data["Mirror Bacteria"].append(max(log(mirror_bacteria_num)/log(10), 0))
	
	grapher.update_graph()

func do_spawn_cycle():
	if will_health <= 0:
		return
	if bacteria_count < bacteria_level or randf() < 0.003 * bacteria_level:
		bacteria_count += 1
		spawns_queue.append([timer + randf_range(0.5, 2.0), spawn_bacteria])
	if mirror_bacteria_count < mirror_bacteria_level or randf() < 0.003 * mirror_bacteria_level:
		mirror_bacteria_count += 1
		spawns_queue.append([timer + randf_range(0.5, 2.0), spawn_mirror_bacteria])
	if immune_cell_count < immune_cell_level or randf() < 0.003 * immune_cell_level:
		immune_cell_count += 1
		spawns_queue.append([timer + randf_range(0.5, 2.0), spawn_immune_cell])
	if glucose_count < glucose_level or randf() < 0.003 * glucose_level:
		glucose_count += 1
		spawns_queue.append([timer + randf_range(0.5, 2.0), spawn_glucose])
	if glycerol_count < glycerol_level or randf() < 0.003 * glycerol_level:
		glycerol_count += 1
		spawns_queue.append([timer + randf_range(0.5, 2.0), spawn_glycerol])
	if c5a_count < c5a_level or randf() < 0.003 * c5a_level:
		c5a_count += 1
		spawns_queue.append([timer + randf_range(0.5, 2.0), spawn_c5a])
	if vaccine_count < vaccine_level or randf() < vaccine_level * 0.01:
		vaccine_count += 1
		spawns_queue.append([timer + randf_range(0.5, 2.0), spawn_vaccine])
		
func generate_spawn_point(y):
	var x_lim = BOUNDS_RECT.size.x - 1
	var y_lim = BOUNDS_RECT.size.y - 1
	var n = randf_range(0, 2 * (x_lim + y_lim))
	if n < x_lim * 2:
		return Vector3(fmod(n, x_lim) - x_lim/2, y, y_lim/2 * sign(n - x_lim))
	else:
		n -= x_lim * 2
		return Vector3(x_lim/2 * sign(n - y_lim), y, fmod(n, y_lim) - y_lim/2)

func spawn_bacteria():
	add_child(Bacteria.instantiate(generate_spawn_point(0.5)))

func spawn_mirror_bacteria():
	add_child(MirrorBacteria.instantiate(generate_spawn_point(0.5)))

func spawn_immune_cell():
	add_child(ImmuneCell.instantiate(generate_spawn_point(0.5)))

func spawn_glucose():
	add_child(Glucose.instantiate(generate_spawn_point(0.2)))

func spawn_glycerol():
	add_child(Glycerol.instantiate(generate_spawn_point(0.2)))
	
func spawn_c5a():
	add_child(C5a.instantiate(generate_spawn_point(0.2)))

func spawn_vaccine():
	add_child(Vaccine.instantiate(generate_spawn_point(0.2)))
