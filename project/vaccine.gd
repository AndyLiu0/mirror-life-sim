class_name Vaccine
extends CharacterBody3D

func _get_class():
	return "Vaccine"

static var scene: PackedScene = preload("res://vaccine.tscn")
var latch_pos = Vector3.ZERO
var latch_r: float
var mesh: MeshInstance3D
var init_scale
var bacteria_box: Area3D
var latch_box: Area3D
var target: MirrorBacteria
var scale_timer = 0

static func instantiate(position):
	var new: Vaccine = scene.instantiate()
	new.position = position
	var vel = clamp(randfn(1.5, 0.3), 1.0, 2.0) * Vector2.RIGHT.rotated(atan2(-position.z, -position.x) + (randf() - 0.5) * PI/3)
	new.velocity = Vector3(vel.x, 0, vel.y)
	new.rotation.y = randf_range(0, 2*PI)
	return new

func _ready():
	bacteria_box = get_node("BacteriaDetectionBox")
	latch_box = get_node("LatchBox")
	mesh = get_node("Mesh")
	init_scale = mesh.scale
	bacteria_box.connect("body_entered", bacteria_check)
	latch_box.connect("body_entered", latch_check)

func _process(delta):
	if scale_timer > 0:
		scale_timer -= min(delta, scale_timer)
		mesh.scale = (0.7 + scale_timer) * init_scale
	if !Globals.BOUNDS_RECT.has_point(Vector2(position.x, position.z)):
		queue_free()
	if latch_pos != Vector3.ZERO:
		if !is_instance_valid(target):
			queue_free()
			return
		if target.die > 0:
			scale_timer = 0
			mesh.scale = 0.7 * (1 - target.die) * init_scale
		position = target.position + latch_pos.rotated(Vector3(0, 1, 0), target.rotation.y)
		rotation.y = target.rotation.y + latch_r
	elif target != null:
		track_target(delta)
		return
	else:
		move_and_slide()

func track_target(delta):
		var d = position.distance_to(target.position)
		velocity += 2 * (target.position - position).normalized() * (2*d + 1) * delta
		velocity *= 0.2**delta
		move_and_slide()

func bacteria_check(body):
	if target != null:
		return
	if body is MirrorBacteria and body.die == 0:
		target = body
		scale_timer = 0.3

func latch_check(body):
	if body is MirrorBacteria and body.die == 0:
		target = body
		latch_pos = (position - body.position).rotated(Vector3(0, 1, 0), -body.rotation.y)
		latch_r = rotation.y - body.rotation.y
		body.marked = true
