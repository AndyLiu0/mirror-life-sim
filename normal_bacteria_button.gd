extends Button

var mouse_box: Area2D

const max_x = 10
const min_x = -200

var target_x = min_x

var sim_node: Node3D

func _ready():
	sim_node = get_node("../../../../Simulation")
	mouse_box = get_node("../MouseBox")
	position.x = target_x
	mouse_box.connect("mouse_entered", _mouse_entered)
	mouse_box.connect("mouse_exited", _mouse_exited)
	connect("button_up", _button_pressed)
	
func _process(delta):
	var diff = target_x - position.x
	if (abs(diff) > 2):
		position.x += clamp(
			delta * (10 * (target_x - position.x) + 10 * sign(diff)),
			-abs(diff),
			abs(diff)
		)
	else:
		position.x = target_x
	return

func _mouse_entered():
	target_x = max_x

func _mouse_exited():
	target_x = min_x
	
func _button_pressed():
	sim_node.bacteria_num += 10000
	
