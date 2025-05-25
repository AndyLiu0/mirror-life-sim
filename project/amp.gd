class_name Amp
extends CharacterBody3D

func _get_class():
	return "Amp"

static var scene: PackedScene = preload("res://amp.tscn")
var timer = 0
var mesh: MeshInstance3D
var init_scale
var bacteria_box: Area3D
var kill_box: Area3D
var kill_box2: Area3D
var target: CharacterBody3D
var orient = 0
var sim: Simulation
var sim_zoom: Button

var tag: Nametag

static var popup_d: PackedScene = preload("res://interaction_popup_d.tscn")
static var popup_e: PackedScene = preload("res://interaction_popup_e.tscn")

static func instantiate(position, velocity):
	var new = scene.instantiate()
	new.position = position
	new.velocity = velocity
	new.rotation.y = randf_range(0, 2*PI)
	return new

func _ready():
	bacteria_box = get_node("BacteriaDetectionBox")
	kill_box = get_node("BacteriaKillBox")
	kill_box2 = get_node("BacteriaKillBox2")
	mesh = get_node("Mesh")
	sim = get_tree().get_current_scene().get_node("Simulation")
	init_scale = mesh.scale
	mesh.scale = init_scale * Vector3(1, 0.5, 0.5)
	bacteria_box.connect("body_entered", _body_entered)
	kill_box.connect("body_entered", kill_check)
	kill_box2.connect("body_entered", kill_check2)
	sim_zoom = get_tree().get_current_scene().get_node("BottomUI/ZoomButton")
	connect("mouse_entered", func(): 
		Nametag.instantiate(self, "AMP", 50))

func _process(delta):
	timer += delta
	if timer < 5:
		if (mesh.scale.y < init_scale.y):
			mesh.scale.y = min(mesh.scale.y + delta * 0.05, init_scale.y)
			mesh.scale.z = min(mesh.scale.z + delta * 0.05, init_scale.z)
		if target != null:
			track_target(delta)
			return
	elif timer < 6:
		mesh.scale.y = init_scale.y * (6 - timer)
		mesh.scale.z = init_scale.z * (6 - timer)
		move_and_slide()
		return
	else:
		queue_free()
		
	move_and_slide()
	if !Globals.BOUNDS_RECT.has_point(Vector2(position.x, position.z)):
		queue_free()

func track_target(delta):
	var diff = target.position - position
	var rel_diff = diff.rotated(Vector3(0, 1, 0), -target.rotation.y)
	var target_pos = target.position + Vector3(abs(rel_diff.x), 0, 0).rotated(Vector3(0, 1, 0), target.rotation.y + PI/2 * sign(rel_diff.z))
	var ang_diff = wrapf(target.rotation.y - (rotation.y + orient*PI/2), -PI/2, PI/2)
	rotation.y += 3 * sign(ang_diff) * delta
	velocity += 8 * delta * (target_pos - position)
	move_and_slide()
	velocity *= 0.04**delta
	target.velocity *= 0.1**delta
	target.speed *= 0.2**delta
	target.omega *= 0.2**delta

func _body_entered(body):
	if target != null:
		return
	if body is Bacteria or (body is MirrorBacteria and body.marked) and body.die == 0:
		target = body
		target.speed *= 0.2
		timer = 0
		get_node("CollisionShape3D").disabled = true
		orient = randi_range(0, 1)
		

func kill_check(body):
	if (body is Bacteria or body is MirrorBacteria) and body.die == 0:
		body.trigger_death()
		timer = 5
		if sim_zoom.button_pressed:
			var p: InteractionPopup = popup_e.instantiate()
			get_tree().get_current_scene().get_node("TopUI").add_child(p)
			var diff = (position - body.position).normalized() * 100
			p.position += sim.camera.unproject_position(body.global_position) + sim.camera.get_node("../..").position + Vector2(diff.x, diff.z)

func kill_check2(body):
	if (body is Bacteria or body is MirrorBacteria) and body.die == 0:
		body.trigger_death()
		timer = 5
		if sim_zoom.button_pressed:
			var p: InteractionPopup = popup_d.instantiate()
			get_tree().get_current_scene().get_node("TopUI").add_child(p)
			var diff = (position - body.position).normalized() * 100
			p.position += sim.camera.unproject_position(body.global_position) + sim.camera.get_node("../..").position + Vector2(diff.x, diff.z)
