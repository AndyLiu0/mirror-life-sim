extends SubViewport

func _process(delta):
	self.size = get_parent().size
	
