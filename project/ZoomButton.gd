extends Button

const padding = 10

var viewport_container: SubViewportContainer
var update_targets
var options: Control

func _ready():
	viewport_container = get_node("/root/Main/Simulation/SimCameraLayer/SimCameraViewportContainer")
	options = get_node("../../UI/Options")
	match_viewport()

func _process(delta):
	if !button_pressed:
		match_viewport()
	
func _toggled(toggled_on):
	if not is_inside_tree():
		return
	options.timer = 0.01 if toggled_on else -0.01
	
	if toggled_on:
		viewport_container.target_rect = viewport_container.RECT_FULL
		self.size = get_viewport_rect().size
		self.position = Vector2.ZERO
		viewport_container.mouse_filter = Control.MOUSE_FILTER_PASS
	else:
		viewport_container.target_rect = viewport_container.RECT_MIN
		viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

func match_viewport():
		self.size = viewport_container.get_rect().size + Vector2(padding*2, padding*2)
		self.position = viewport_container.get_rect().position - Vector2(padding, padding)
