class_name ImmuneCell
extends CharacterBody3D

static var scene: PackedScene = preload("res://ImmuneCell.tscn")

var impulse = Vector2.ZERO
var speed = 0.0

var mesh: MeshInstance3D
var cell_box: Area3D

var queue_check = true
var impulse_timer = 3

var reset_impulse = false

var leave = false

static func instantiate(position):
	var new: ImmuneCell = scene.instantiate()
	new.position = position
	new.speed = 0
	return new

func _ready():
	mesh = get_node("Mesh")
	cell_box = get_node("CellDetectionBox")

func _process(delta):
	if queue_check:
		queue_check = false
		check_target()
	
	if Globals.IN_RECT.has_point(Vector2(position.x, position.z)):
		if reset_impulse:
			impulse = Vector2.ZERO
			reset_impulse = false
		leave = randf() < 1 if get_parent().immune_cell_count > get_parent().immune_cell_level else 0.1
		impulse_timer -= min(impulse_timer, delta)
		if impulse_timer == 0:
			if impulse == Vector2.ZERO:
				impulse_timer = randf_range(3.0, 5.0)
				var ang = (atan2(-position.z, -position.x) + randf_range(-PI/6, PI/6)) if randf() < 0.3 else randf_range(0, 2*PI)
				impulse = randf_range(1.3, 1.8) * Vector2.from_angle(ang)
			else:
				impulse_timer = randf_range(1.0, 2.0)
				impulse = Vector2.ZERO
	else:
		if !Globals.BOUNDS_RECT.has_point(Vector2(position.x, position.z)):
			get_parent().immune_cell_count -= 1
			queue_free()
		if !leave:
			var x = sign(position.x) / ((position.x - Globals.BOUNDS_RECT.position.x) * (position.x - Globals.BOUNDS_RECT.position.x - Globals.BOUNDS_RECT.size.x))
			var y = sign(-position.z) / ((-position.z - Globals.BOUNDS_RECT.position.y) * (-position.z - Globals.BOUNDS_RECT.position.y - Globals.BOUNDS_RECT.size.y))
			impulse = 40 * Vector2(x, -y)
			reset_impulse = true
				
	if impulse != Vector2.ZERO:
		velocity *= 0.3**delta
		velocity += delta * Vector3(impulse.x, 0, impulse.y)
	move_and_slide()
	
func check_target():
	var bodies = cell_box.get_overlapping_bodies()
	var i = 0
	for body in bodies:
		if body is Bacteria or (body is MirrorBacteria and body.marked) and randf() < 1.0/(len(bodies)-1):
			get_parent().add_child(Amp.instantiate(position, randf_range(2.5, 3)*(body.position - position).normalized() + Vector3(0.5, 0, 0).rotated(Vector3(0, 1, 0), randf_range(-PI, PI))))
			break
		i += 1
	if randf() < get_parent().immune_activation * 0.5:
		get_parent().add_child(Amp.instantiate(position, Vector3(randf_range(0.5, 1.0), 0, 0).rotated(Vector3(0, 1, 0), randf_range(-PI, PI))))
	await get_tree().create_timer(randf_range(1, 2)).timeout
	queue_check = true
	
