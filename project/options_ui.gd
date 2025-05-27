extends Control

var timer = -1
var min_x = position.x
var max_x = 0

func _process(delta):
	if abs(timer) == 1:
		return
	if timer > 0:
		timer += delta
		if timer > 1:
			timer = 1
			position.x = max_x
		else:
			position.x = max_x - (max_x - min_x) * (1 - timer) ** 2
	else:
		timer -= delta
		if timer < -1:
			timer = -1
			position.x = min_x
		else:
			position.x = max_x + (min_x - max_x) * timer ** 2
