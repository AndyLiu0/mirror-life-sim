class_name Bacteria
extends CharacterBody3D

func _get_class():
	return "Bacteria"

static var scene: PackedScene = preload("res://Bacteria.tscn")

const MAX_SPEED = 5.0
const FRICTION = 0.93

var target_omega = 0.0
var omega = 0.0

const default_speed = 1.0
var speed = 0.0

var mesh: MeshInstance3D
var molecule_box: Area3D

var queue_check = true

var leave = false

var die = 0

var mesh_mat: StandardMaterial3D

static func instantiate(position):
	var new: Bacteria = scene.instantiate()
	new.position = position
	new.rotation.y = atan2(position.z, -position.x)
	new.speed = randf_range(MAX_SPEED * 0.3, MAX_SPEED * 0.8)
	return new

func _ready():
	mesh = get_node("BacteriaMesh")
	molecule_box = get_node("MoleculeDetectionBox")

func trigger_death():
	die = 0.01
	mesh_mat = StandardMaterial3D.new()
	mesh_mat.albedo_color = mesh.get_surface_override_material(0).albedo_color
	mesh_mat.transparency = 1
	mesh.set_surface_override_material(0, mesh_mat)
	get_node("Hitbox").disabled = true
	
func _process(delta):
	if die != 0:
		die += delta
		mesh.scale += Vector3(0.2, 0.2, 0.2) * delta
		mesh_mat.albedo_color.a -= delta
		if die >= 1:
			get_parent().bacteria_count -= 1
			queue_free()
		return
		
	if randf() < clamp(abs(speed - default_speed)**3 * 4 + 0.6, 0, 1/delta) * delta:
		speed = clamp(speed + randfn(0, 1), -MAX_SPEED/4, MAX_SPEED)
	
	var impulse = Vector2.ZERO

	if target_omega == 0:
		if randf() < delta:
			target_omega = clamp(randfn(90, 30), 30, 120) * randi_range(-1, 1)
	elif randf() < delta * abs(target_omega) / 30:
		target_omega = 0

	if queue_check:
		queue_check = false
		check_target()
	
	if Globals.IN_RECT.has_point(Vector2(position.x, position.z)):
		leave = randf() < 1 if get_parent().bacteria_count > get_parent().bacteria_level else 0.2
	else:
		if !Globals.BOUNDS_RECT.has_point(Vector2(position.x, position.z)):
			get_parent().bacteria_count -= 1
			queue_free()
		if !leave:
			var x = sign(position.x) / ((position.x - Globals.BOUNDS_RECT.position.x) * (position.x - Globals.BOUNDS_RECT.position.x - Globals.BOUNDS_RECT.size.x))
			var y = sign(-position.z) / ((-position.z - Globals.BOUNDS_RECT.position.y) * (-position.z - Globals.BOUNDS_RECT.position.y - Globals.BOUNDS_RECT.size.y))
			omega += 2.5 * wrapf(atan2(sign(speed) * y, sign(speed) * x) - rotation.y, -PI, PI)
			impulse += 0.5 * Vector2(x, -y)
		
	impulse += speed * Vector2.RIGHT.rotated(-rotation.y) * (1 - (1 - FRICTION)**delta)
		
	velocity += Vector3(impulse.x, 0, impulse.y)
	velocity *= (1-FRICTION)**delta
	
	omega += target_omega * (1 - (1 - FRICTION)**delta)
	rotate_y(omega * delta * PI/180)
	
	mesh.rotate_x(speed * delta * 30)
	
	if abs(omega) < 0.1:
		omega = 0
	else:
		omega *= (1-FRICTION)**delta
	move_and_slide()
	
func check_target():
	if Globals.IN_RECT.has_point(Vector2(position.x, position.z)):
		for a in molecule_box.get_overlapping_areas():
			var b = a.get_parent()
			if b is Glucose:
				target_omega = 0
				var d = position.distance_to(b.position)
				var v_mult = 0.5 * d/max(speed, 0.3)
				var ang_diff = wrapf(atan2(position.z - (b.position.z + b.linear_velocity.z * v_mult), (b.position.x + b.linear_velocity.x * v_mult) - position.x) - rotation.y, -PI, PI)
				omega += 4 * ang_diff
				if abs(ang_diff) < PI/6 && randf() < 0.5:
					speed += 2
				queue_check = true
				return
	await get_tree().create_timer(randf_range(0.5, 2)).timeout
	queue_check = true
	
