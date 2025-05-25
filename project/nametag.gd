class_name Nametag

extends Control

var label: Label
var text: String
var target: Node3D
var off: int

var timer = 0
var cam_viewport_container: SubViewportContainer
var cam: Camera3D

const lifespan = 2.0
const t = 1/5.0

static var scene: PackedScene = preload("res://nametag.tscn")

const max_scale = Vector2(1, 1)

var prep = true
var pause = false

static func instantiate(target, text, off):
	if target.tag == null:
		var new = scene.instantiate()
		new.text = " %s " % text
		new.target = target
		new.off = off
		target.get_tree().get_current_scene().get_node("TopUI").add_child(new)
		return new

func _ready():
	target.tag = self
	label = get_node("Label")
	label.text = text
	cam_viewport_container = get_tree().get_current_scene().get_node("Simulation/SimCameraLayer/SimCameraViewportContainer")
	cam = cam_viewport_container.get_node("SimCameraViewport/SimCamera")
	target.connect("mouse_entered", mouse_enter)
	target.connect("mouse_exited", mouse_exit)
	
func _process(delta):
	if prep:
		prep = false
		label.position = -label.size/2.0
		label.pivot_offset = label.size/2.0
	if is_instance_valid(target):
		position = cam.unproject_position(target.global_position) + cam_viewport_container.position + Vector2(0, off)
	else:
		pause = false
		timer = max(timer, lifespan - t)
	if !pause or timer < t:
		timer += delta
	if timer < t:
		var s = (timer/t)**2
		scale = s*max_scale
	elif timer < lifespan - t:
		scale = max_scale
	elif timer < lifespan:
		var s = 1 - ((timer - (lifespan - t))/t)**2
		scale = s*max_scale
	else:
		if is_instance_valid(target):
			target.tag = null
		queue_free()

func mouse_enter():
	if is_instance_valid(target):
		pause = true
		if timer > lifespan - t:
			timer = lifespan - timer

func mouse_exit():
	pause = false
	if is_instance_valid(target):
		timer = min(timer, t)
