class_name C5a
extends CharacterBody3D

func _get_class():
	return "C5a"

static var scene: PackedScene = preload("res://c5a.tscn")

var hitbox: Area3D

static func instantiate(position):
	var new: C5a = scene.instantiate()
	new.position = position
	var vel = clamp(randfn(1.5, 0.3), 1.0, 2.0) * Vector2.RIGHT.rotated(atan2(-position.z, -position.x) + (randf() - 0.5) * PI/3)
	new.velocity = Vector3(vel.x, 0, vel.y)
	return new
	
func _ready():
	hitbox = get_node("Killbox")
	hitbox.connect("body_entered", body_entered)	
	
func _process(delta):
	move_and_slide()
	if !Globals.BOUNDS_RECT.has_point(Vector2(position.x, position.z)):
		get_parent().c5a_count -= 1
		queue_free()
	
func body_entered(body):
	if body is MirrorBacteria:
		body.trigger_death()
