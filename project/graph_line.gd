class_name GraphLine
extends Line2D

var datapoints: Array
var x_factor: float
var y_factor: float
var y_size: float

func _ready():
	width = 4
	self.visible = false

func add_datapoint(point: Vector2):
	datapoints.append(point)
	add_point(Vector2(point.x * x_factor, y_size - point.y * y_factor))
	print(points[-1])
	
func set_x_factor(x_coeff: float):
	x_factor = x_coeff
	for i in range(len(points)):
		points[i].x = datapoints[i].x * x_factor

func reset():
	clear_points()
	for p in datapoints:
		add_point(Vector2(p.x * x_factor, y_size -p.y * y_factor))
