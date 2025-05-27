class_name Eye
extends Node3D

var pupil_node: Node3D
var pupil_mesh: MeshInstance3D

var pupil_init_pos = position

const white_max = PI/15
const pupil_max = PI/30

func _ready():
	pupil_node = get_node("PupilNode")
	pupil_mesh = get_node("PupilNode/PupilMesh")
	
func turn_angle(angle: Vector2):
	pupil_node.rotation.z = clamp(angle.x * 0.5, -pupil_max, pupil_max)
	pupil_node.rotation.y = clamp(angle.y * 0.5, -pupil_max, pupil_max)
	rotation.z = clamp(angle.x - pupil_node.rotation.z, -white_max, 0)
	rotation.y = clamp(angle.y - pupil_node.rotation.y, -white_max, white_max)
	
func get_angle(target: Vector3):
	var diff = target - global_position
	return Vector2(atan2(diff.x, diff.y), atan2(diff.z, diff.y))
