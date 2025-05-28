extends Control

var sim: Simulation

func _ready():
	sim = get_node("../../Simulation")
	get_node("Button").connect("pressed", sim.reset)
