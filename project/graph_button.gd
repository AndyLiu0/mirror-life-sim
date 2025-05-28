extends Control

var grapher: Grapher

func _ready():
	grapher = get_node("../GraphUI/VLayout/GridContainer/GraphSpace")
	get_node("Button").connect("pressed", grapher.toggle_visible)
