extends SubViewportContainer

const size_min = Vector2(300, 200)
const kP = 5
const kS = 10
const padding_min = 30
const padding_full = 100

var SCREEN_SIZE = Vector2(
	ProjectSettings.get("display/window/size/viewport_width"),
	ProjectSettings.get("display/window/size/viewport_height")
)

@export var RECT_MIN: Rect2 = Rect2(
		SCREEN_SIZE - size_min - Vector2(padding_min, padding_min),
		size_min
	)
@export var RECT_FULL: Rect2 = Rect2(
		Vector2(padding_full, padding_full),
		SCREEN_SIZE - Vector2(padding_full*2, padding_full*2)
	)
@export var target_rect: Rect2 = RECT_MIN

var viewport: SubViewport

func _ready():
	position = target_rect.position
	size = target_rect.size
	viewport = get_child(0)
	return
	
func _process(delta):
	if (abs(position.x - target_rect.position.x)) > kS * delta:
		position.x += delta * (kP * (target_rect.position.x - position.x) 
			+ kS * sign(target_rect.position.x - position.x))
	else:
		position.x = target_rect.position.x

	if (abs(position.y - target_rect.position.y)) > kS * delta:
		position.y += delta * (kP * (target_rect.position.y - position.y)
			+ kS * sign(target_rect.position.y - position.y))
	else:
		position.y = target_rect.position.y
		
	if (abs(size.x - target_rect.size.x)) > kS * delta:
		viewport.size.x += delta * (kP * (target_rect.size.x - size.x)
			+ kS * sign(target_rect.size.x - size.x))
		size.x += delta * (kP * (target_rect.size.x - size.x)
			+ kS * sign(target_rect.size.x - size.x))
	else:
		viewport.size.x = target_rect.size.x
		size.x = target_rect.size.x
		
	if (abs(size.y - target_rect.size.y)) > kS * delta:
		viewport.size.y += delta * (kP * (target_rect.size.y - size.y)
			+ kS * sign(target_rect.size.y - size.y))
		size.y += delta * (kP * (target_rect.size.y - size.y)
			+ kS * sign(target_rect.size.y - size.y))
	else:
		viewport.size.y = target_rect.size.y
		size.y = target_rect.size.y
	
