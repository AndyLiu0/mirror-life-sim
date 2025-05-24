class_name StatUI
extends Node2D

var sim_zoom: Button
var timer: float
var style_changed: bool

var init_pos: Vector2
var init_pos2 = position
var target_diff: Vector2
var target_diff2 = Vector2.ZERO

var label: Label
var style_box: StyleBoxFlat

var bottom_x: int
var right_y: int

func _ready():
	sim_zoom = get_tree().get_current_scene().get_node("BottomUI/ZoomButton")
	sim_zoom.connect("toggled", update_ui)
	label = get_node("Label")
	style_box = label.get("theme_override_styles/normal")

func _process(delta):
	if timer > 0:
		if timer > 0.4:
			position = init_pos + target_diff * (2.5 * (1 - timer)) ** 2
		else:
			if !style_changed:
				if sim_zoom.button_pressed:
					style_box.corner_radius_bottom_left = 0
					style_box.corner_radius_top_right = 16
				else:
					style_box.corner_radius_bottom_left = 16
					style_box.corner_radius_top_right = 0
				style_changed = true
			position = init_pos2 + target_diff2 * (1 - (2.5 * (timer)) ** 2)
		timer -= delta
	if timer <= 0:
		position = init_pos2 + target_diff2
	
func update_ui(zoom):
	if zoom:
		init_pos = position
		target_diff = Vector2(label.get_rect().size.x, 0)
		init_pos2 = Vector2(bottom_x, Globals.SCREEN_SIZE.y)
		target_diff2 = Vector2(0, -label.get_rect().size.y)
	else:
		init_pos = position
		target_diff = Vector2(0, label.get_rect().size.y)
		init_pos2 = Vector2(Globals.SCREEN_SIZE.x, right_y)
		target_diff2 = Vector2(-label.get_rect().size.x, 0)
	timer = 1
	style_changed = false
