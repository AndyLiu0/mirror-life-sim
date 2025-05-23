class_name Glycerol
extends RigidBody3D

func _get_class():
	return "Glycerol"

static var scene: PackedScene = preload("res://glycerol.tscn")

var target: MirrorBacteria = null

var hitbox: Area3D

static func instantiate(position):
	var new: Glycerol = scene.instantiate()
	new.position = position
	var vel = clamp(randfn(1, 0.3), 0.7, 1.3) * Vector2.RIGHT.rotated(atan2(-position.z, -position.x) + (randf() - 0.5) * PI/3)
	new.linear_velocity = Vector3(vel.x, 0, vel.y)
	return new
	
func _ready():
	hitbox = get_node("Hitbox")
	hitbox.connect("body_entered", body_entered)
	
func _process(delta):
	if target == null:
		move_and_collide(linear_velocity * delta)
		if !Globals.BOUNDS_RECT.has_point(Vector2(position.x, position.z)):
			get_parent().glycerol_count -= 1
			queue_free()
	else:
		var d = position.distance_to(target.position)
		if (d < 0.3):
			get_parent().glycerol_count -= 1
			queue_free()
		move_and_collide((target.position - position).normalized() * (2*d + 1) * delta)
		var f = clamp(d, 0.3, 1)
		self.scale = Vector3(f, f, f)
	
func body_entered(body):
	if target == null and body is MirrorBacteria:
		target = body
