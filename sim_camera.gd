extends Camera3D

var viewport: SubViewport

func _ready():
	viewport = get_parent()

func _process(delta):
	position.y = sqrt(viewport.size.x) * 0.6
