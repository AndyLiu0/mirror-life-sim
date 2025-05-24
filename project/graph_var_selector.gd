extends HBoxContainer

var button: Button
var label: Label
var grapher: Grapher

func _ready():
	button = get_node("CheckButton")
	label = get_node("Label")
	button.connect("button_down", update_graph)
	
func update_graph():
	grapher.update_y(label.text)
