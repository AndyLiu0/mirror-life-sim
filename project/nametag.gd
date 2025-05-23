class_name Nametag

extends Node3D

var text: String
var target: Node3D

var timer = 2

static func instantiate(text, target):
	var new = Nametag.new()
	new.text = text

func _ready():
	get_node("Label").text = text

func _process(delta):
	timer -= delta
	self.position = target.position + Vector3(0, 0, 1.5)
	if timer <= 0:
		queue_free()
