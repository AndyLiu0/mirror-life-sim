class_name Simulation
extends Node3D

var health_label: Label
var immune_label: Label
var bacteria_label: Label
var mirror_label: Label

var BOUNDS_RECT: Rect2
var IN_RECT: Rect2

var will_health = 1

var bacteria_limit: float = 10 ** 10

var bacteria_num: float = 0
var bacteria_level = 0
var bacteria_count = 0

var mirror_bacteria_num: float = 0
var mirror_bacteria_level = 0
var mirror_bacteria_count = 0

var immune_activation = 0
var complement_activation = 0
var vaccine_effect = 0

var glucose_level = 2
var glucose_count = 0

var glycerol_level = 2
var glycerol_count = 0

var c5a_level = 1
var c5a_count = 0

var immune_cell_level = 2
var immune_cell_count = 0

var timer = 0

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
		
func _process(delta):
	if timer > 0.5:
		update_sim()
		do_spawn_cycle()
		timer = 0
	timer += delta

func calc_bacteria(num, immunity):
	return int(num + 0.3 * num * (1 - (bacteria_num + mirror_bacteria_num)/bacteria_limit) * (1 - immunity/3) - (sqrt(num) * 3 * 10**2 + num / 3) * immunity**2 * (log(num)**2) / (max(log(bacteria_num), 0)**2 + max(log(mirror_bacteria_num), 0)**2))

func reset():
	for node in get_children():
		break
	

func update_sim():
	if will_health > 0:
		will_health += min(0.02, 0.1 * will_health) - 0.001 * clamp(log(bacteria_num + mirror_bacteria_num)/log(10), 0, 20)**2 + (1 - will_health) * 0.06
		will_health = clamp(will_health, 0, 1)
	var diff = 3 * 10**10 * sqrt(will_health) - bacteria_limit
	bacteria_limit += 0.2 * diff + 10**6 * sign(diff)
	bacteria_limit = clamp(bacteria_limit, 0, 3 * 10**10)
	immune_activation *= 0.95
	immune_activation += 0.01 * clamp(log(bacteria_num)/log(10), 0, 20) - 0.025 + 0.01 * clamp(log(mirror_bacteria_num)/log(10), 0, 20) * vaccine_effect
	immune_activation = clamp(immune_activation, 0, min(sqrt(will_health/0.4), 1))
	complement_activation *= 0.92
	complement_activation += 0.2 * (1 - will_health) - 0.01
	complement_activation = min(max(complement_activation, 0.1), min(sqrt(will_health/0.4), 1))
	bacteria_num = max(0, calc_bacteria(bacteria_num, immune_activation + complement_activation * 0.3))
	mirror_bacteria_num = max(0, calc_bacteria(mirror_bacteria_num, immune_activation + complement_activation * 0.3))
	
	health_label.text = "Health\n%s%%" % int(will_health * 100)
	immune_label.text = "Immune Activity\n%s%% / %s%%" % [int(round(immune_activation * 100)), int(round(complement_activation * 100))]
	if bacteria_num < 10000:
		bacteria_label.text = "Bacteria\n%s CFU" % int(bacteria_num)
	else:
		bacteria_label.text = "Bacteria\n%s e%s CFU" % [0.1 * int(10 * bacteria_num / 10**int(log(bacteria_num)/log(10))), int(log(bacteria_num)/log(10))]
	if mirror_bacteria_num < 10000:
		mirror_label.text = "Mirror Bacteria\n%s CFU" % int(mirror_bacteria_num)
	else:
		mirror_label.text = "Mirror Bacteria\n%s e%s CFU" % [0.1 * int(10 * mirror_bacteria_num / 10**int(log(mirror_bacteria_num)/log(10))), int(log(mirror_bacteria_num)/log(10))]
	
	bacteria_level = int(1 * max(0, log(bacteria_num))/log(10)) - 3
	mirror_bacteria_level = int(1 * max(0, log(mirror_bacteria_num))/log(10)) - 3
	immune_cell_level = (int(immune_activation * 4) + 1) if will_health > 0 else 0
	glucose_level = round(2 * min(sqrt(will_health) * 2, 1))
	glycerol_level = round(2 * min(sqrt(will_health) * 2, 1))
	c5a_level = ceil(complement_activation * 3)

func do_spawn_cycle():
	if bacteria_count < bacteria_level or randf() < 0.003 * bacteria_level:
		spawn_bacteria()
	if mirror_bacteria_count < mirror_bacteria_level or randf() < 0.003 * mirror_bacteria_level:
		spawn_mirror_bacteria()
	if immune_cell_count < immune_cell_level or randf() < 0.003 * immune_cell_level:
		spawn_immune_cell()
	if glucose_count < glucose_level or randf() < 0.003 * glucose_level:
		spawn_glucose()
	if glycerol_count < glycerol_level or randf() < 0.003 * glycerol_level:
		spawn_glycerol()
	if c5a_count < c5a_level or randf() < 0.003 * c5a_level:
		spawn_c5a()
	if will_health > 0 and randf() < vaccine_effect * 0.15:
		spawn_vaccine()

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
	bacteria_count += 1
	#await get_tree().create_timer(randf_range(0.5, 3)).timeout
	add_child(Bacteria.instantiate(generate_spawn_point(0.5)))

func spawn_mirror_bacteria():
	mirror_bacteria_count += 1
	#await get_tree().create_timer(randf_range(0.5, 3)).timeout
	add_child(MirrorBacteria.instantiate(generate_spawn_point(0.5)))

func spawn_immune_cell():
	immune_cell_count += 1
	#await get_tree().create_timer(randf_range(0.5, 3)).timeout
	add_child(ImmuneCell.instantiate(generate_spawn_point(0.5)))

func spawn_glucose():
	glucose_count += 1
	#await get_tree().create_timer(randf_range(0.5, 3)).timeout
	add_child(Glucose.instantiate(generate_spawn_point(0.2)))

func spawn_glycerol():
	glycerol_count += 1
	#await get_tree().create_timer(randf_range(0.5, 3)).timeout
	add_child(Glycerol.instantiate(generate_spawn_point(0.2)))
	
func spawn_c5a():
	c5a_count += 1
	add_child(C5a.instantiate(generate_spawn_point(0.2)))

func spawn_vaccine():
	add_child(Vaccine.instantiate(generate_spawn_point(0.2)))
