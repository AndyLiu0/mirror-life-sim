class_name AddButton
extends Button

var mouse_box: Area2D

const max_x = 10
const min_x = -170

var target_x = max_x

var sim_node: Node3D
var sim_zoom: Button

var space_state: PhysicsDirectSpaceState2D
var collision_params = PhysicsPointQueryParameters2D.new()

var syringe_target: MeshInstance3D

func _ready():
	sim_node = get_node("../../../../Simulation")
	sim_zoom = get_node("../../../../BottomUI/ZoomButton")
	mouse_box = get_node("../MouseBox")
	position.x = min_x
	mouse_box.connect("mouse_entered", _mouse_entered)
	mouse_box.connect("mouse_exited", _mouse_exited)
	connect("button_up", _button_pressed)
	sim_zoom.connect("toggled", update_ui)
	space_state = get_world_2d().direct_space_state
	collision_params.canvas_instance_id = get_canvas_layer_node().get_instance_id()
	collision_params.collide_with_areas = true
	collision_params.collide_with_bodies = false
	
	syringe_target = get_node("../../../../Room/IVinsert")
	
func _process(delta):
	if sim_zoom.button_pressed:
		collision_params.position = get_global_mouse_position()
		target_x = min_x
		for area in space_state.intersect_point(collision_params):
			if area.collider == mouse_box:
				target_x = max_x
				break
		
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
	get_tree().get_current_scene().add_child(Syringe.instantiate(Vector3(-3, 1, 0), syringe_target.global_position, syringe_target.rotation))
	await get_tree().create_timer(2.0).timeout
	button_action()
	
func button_action():
	pass
