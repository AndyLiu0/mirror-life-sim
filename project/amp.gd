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
var mirror_kill_box: Area3D
var target: CharacterBody3D

static func instantiate(position, velocity):
	var new = scene.instantiate()
	new.position = position
	new.velocity = velocity
	new.rotation.y = randf_range(0, 2*PI)
	return new

func _ready():
	bacteria_box = get_node("BacteriaDetectionBox")
	kill_box = get_node("BacteriaKillBox")
	mesh = get_node("Mesh")
	mirror_kill_box = get_node("MirrorKillBox")
	init_scale = mesh.scale
	mesh.scale = init_scale * Vector3(1, 0.5, 0.5)
	bacteria_box.connect("body_entered", _body_entered)
	kill_box.connect("body_entered", kill_check)
	mirror_kill_box.connect("body_entered", mirror_kill_check)

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
	var target_pos = target.position + Vector3(abs(rel_diff.x)/2, 0, 0).rotated(Vector3(0, 1, 0), target.rotation.y + PI/2 * sign(rel_diff.z))
	var ang_diff = wrapf(target.rotation.y - rotation.y, -PI/2, PI/2)
	rotation.y += 3 * sign(ang_diff) * delta
	velocity += 8 * delta * (target_pos - position)
	move_and_slide()
	velocity *= 0.06**delta
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

func kill_check(body):
	if body is Bacteria and body.die == 0:
		body.trigger_death()
		timer = 5

func mirror_kill_check(body):
	if body is MirrorBacteria and body.die == 0:
		body.trigger_death()
		timer = 5
		
