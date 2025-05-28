extends Control

var space_state: PhysicsDirectSpaceState2D
var collision_params = PhysicsPointQueryParameters2D.new()

var mouse_box: Area2D

var grapher: Grapher
var sim_button: Button

var target_y = 0

func _ready():
	mouse_box = get_node("VBoxContainer/Area2D")
	space_state = get_world_2d().direct_space_state
	collision_params.canvas_instance_id = get_canvas_layer_node().get_instance_id()
	collision_params.collide_with_areas = true
	collision_params.collide_with_bodies = false
	
	grapher = get_node("../GraphUI/VLayout/GridContainer/GraphSpace")
	sim_button = get_node("../../BottomUI/ZoomButton")
	
func _process(delta):
	if !grapher.open and sim_button.button_pressed:
		target_y = 680
		collision_params.position = get_global_mouse_position()
		if collision_params.position.y > 710:
			collision_params.position.y = 710
		for area in space_state.intersect_point(collision_params):
			if area.collider == mouse_box:
				target_y = 510
				break
	else:
		target_y = 720
	position.y = target_y
	
