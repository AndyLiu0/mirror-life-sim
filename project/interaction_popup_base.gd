class_name InteractionPopup
extends Control

var timer = 0
var control: Control
var mouse_box: Area2D
var pause = false

const max_scale = Vector2(0.8, 0.8)

func _ready():
	control = get_node("Control")
	control.scale = Vector2.ZERO
	mouse_box = get_node("MouseBox")
	mouse_box.connect("mouse_entered", mouse_enter)
	mouse_box.connect("mouse_exited", mouse_exit)
	pause = get_rect().has_point(get_global_mouse_position())

func _process(delta):
	if pause:
		if !get_rect().has_point(get_global_mouse_position()):
			pause = false
	if !pause or timer < 1.0/3:
		timer += delta
	if timer < 1.0/3:
		var s = (timer * 3)**2
		control.scale = s*max_scale
	elif timer < 2 - 1.0/3:
		control.scale = max_scale
	elif timer < 2:
		var s = 1 - (3*(timer - (2 - 1.0/3)))**2
		control.scale = s*max_scale
	else:
		queue_free()
	
func mouse_enter():
	pause = true
	if timer > 2 - 1.0/3:
		timer = 2 - timer

func mouse_exit():
	pause = false
	timer = 1.0/3
