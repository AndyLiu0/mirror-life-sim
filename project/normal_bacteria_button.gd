extends Button

var mouse_box: Area2D

const max_x = 10
const min_x = -200

var target_x = max_x

var sim_node: Node3D
var sim_zoom: Button

func _ready():
	sim_node = get_node("../../../../Simulation")
	sim_zoom = get_node("../../../../BottomUI/ZoomButton")
	mouse_box = get_node("../MouseBox")
	position.x = min_x
	mouse_box.connect("mouse_entered", _mouse_entered)
	mouse_box.connect("mouse_exited", _mouse_exited)
	connect("button_up", _button_pressed)
	sim_zoom.connect("toggled", update_ui)
	
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
	if sim_zoom.button_pressed:
		target_x = min_x
	
func update_ui(zoom):
	target_x = min_x if zoom else max_x
	
func _button_pressed():
	sim_node.bacteria_num += 10000
