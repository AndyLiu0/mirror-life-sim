class_name Syringe
extends Node3D

static var scene: PackedScene = preload("res://syringe.tscn")

static func instantiate(position, target, rotation):
	var new: Syringe = scene.instantiate()
	new.position = position
	new.init_position = position
	new.target = target
	new.rotation = rotation
	return new

var plunger: MeshInstance3D
const max_ext = 1
var target: Vector3 
var target_extension: float
var at_target: bool
var init_position
var timer = -0.01
var stage = 0

func _ready():
	plunger = get_node("Node3D/Main/Plunger")
	at_target = false
	plunger.position.z = max_ext
	target_extension = max_ext

func next_stage():
	stage += 1
	if stage == 1:
		timer = 0.5
	if stage == 2:
		target_extension = 0
	if stage == 3:
		timer = 1
	if stage == 4:
		target = init_position
	if stage == 5:
		queue_free()

func _process(delta):
	timer -= min(abs(timer), delta)
	if timer == 0:
		timer = -0.02
		next_stage()
	var diff = target - global_position
	at_target = diff.length() < delta
	if at_target:
		if global_position != target:
			global_position = target
			next_stage()
	else:
		global_position += diff.normalized() * (diff.length() + 1) * delta
	diff = target_extension - plunger.position.z
	if abs(diff) < max_ext * delta:
		if plunger.position.z != target_extension:
			plunger.position.z = target_extension
			next_stage()
	else:
		plunger.position.z += delta * max_ext * sign(diff)
		
	
func set_ext(ext: float):
	target_extension = clamp(ext, 0, max_ext)
