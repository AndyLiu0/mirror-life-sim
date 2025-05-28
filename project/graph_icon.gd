extends Label

func _draw():
	draw_line(Vector2(10, size.y - 10), Vector2(10 + (size.x - 20)/3, 10 + (size.x - 20)/3), Color.DARK_CYAN, 3)
	draw_line(Vector2(10 + (size.x - 20)/3, 10 + (size.x - 20)/3), Vector2(10 + 2*(size.x - 20)/3, 10 + 2*(size.x - 20)/3), Color.DARK_CYAN, 3)
	draw_line(Vector2(10 + 2*(size.x - 20)/3, 10 + 2*(size.x - 20)/3), Vector2(size.x - 10, 10), Color.DARK_CYAN, 3)

	draw_line(Vector2(10, 10), Vector2(10, size.y - 10), Color.BLACK, 3)
	draw_line(Vector2(size.x - 10, size.y - 10), Vector2(10, size.y - 10), Color.BLACK, 3)
