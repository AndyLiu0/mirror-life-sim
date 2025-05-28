extends Label

func _draw():
	draw_arc(Vector2(size.x/2, size.y/2), size.x/4, PI/6, 7*PI/4, 13, Color.WHITE, 4)
	var head = Vector2(size.x * (0.5 + sqrt(2)/8), size.y * (0.5 - sqrt(2)/8))
	#draw_circle(head, 3, Color.WHITE)
	draw_line(head, head + Vector2(0, -(size.y/6)), Color.WHITE, 4)
	draw_line(head, head + Vector2(-size.x/6, 5), Color.WHITE, 4)
