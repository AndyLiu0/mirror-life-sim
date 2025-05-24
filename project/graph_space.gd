class_name Grapher
extends Control

var sim: Simulation

var x_ticks_node: HBoxContainer
var y_ticks_node: VBoxContainer
var v_select_container: HBoxContainer
var y_label_node: Label
var line: Line2D
var full_ui: Control

const num_x_ticks = 12
const num_y_ticks = 10

const tick_length = 7

var x_scale: float
var y_scale: float

var y_var: String

var graph_settings: Dictionary

var tick_label_scene: PackedScene = preload("res://tick_label.tscn")
var var_selector_scene: PackedScene = preload("res://graph_var_selector.tscn")


func _ready():
	var percent_ticks = range(10, 110, 10)
	var log_ticks = range(1, 11)
	for i in len(log_ticks):
		log_ticks[i] = "10^%s" % log_ticks[i]
		
	graph_settings = {
		"Health": ["Health (%)", percent_ticks, 10, Color.LIME_GREEN],
		"Immune Activity": ["Immune Activity (%)", percent_ticks, 10, Color.ORANGE],
		"Bacteria": ["Bacteria (CFU)", log_ticks, 1, Color.DARK_GREEN],
		"Mirror Bacteria": ["Mirror Bacteria (CFU)", log_ticks, 1, Color.DARK_BLUE]
	}
	
	sim = get_tree().get_current_scene().get_node("Simulation")
	x_scale = 5
	x_ticks_node = get_node("../XTicks")
	y_ticks_node = get_node("../YTicks")
	v_select_container = get_node("../../../Options")
	y_label_node = get_node("../YLabelControl/YLabel")
	line = get_node("Line2D")
	full_ui = get_tree().get_current_scene().get_node("UI/GraphUI")

	
	var c: Control = Control.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.size_flags_stretch_ratio = 0.5
	x_ticks_node.add_child(c)
	
	for i in range(num_x_ticks):
		var l: Label = tick_label_scene.instantiate()
		l.text = str(x_scale*(i + 1))
		x_ticks_node.add_child(l)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.size_flags_vertical = Control.SIZE_EXPAND_FILL

	x_ticks_node.add_child(c)
	
	for v in graph_settings.keys():
		var s: HBoxContainer = var_selector_scene.instantiate()
		s.get_node("Label").text = v
		s.grapher = self
		v_select_container.add_child(s)

func _input(event):
	if event.is_action_pressed("ui_graph_toggle"):
		full_ui.visible = !full_ui.visible

func _draw():
	draw_line(Vector2.ZERO, Vector2(0, size.y), Color.BLACK, 2.0)
	draw_line(Vector2(0, size.y), Vector2(size.x, size.y), Color.BLACK, 2.0)
	for t in range(num_x_ticks):
		var x = (t + 1)*2/float(2*num_x_ticks + 1) * size.x
		draw_line(Vector2(x, size.y), Vector2(x, size.y + tick_length), Color.BLACK, 2)
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color.GRAY, 1)

	for t in range(num_y_ticks):
		var y = (t*2+1)/float(2*num_y_ticks + 1) * size.y
		draw_line(Vector2(-tick_length, y), Vector2(0, y), Color.BLACK, 2)
		draw_line(Vector2(0, y), Vector2(size.x, y), Color.GRAY, 1)
			

func update_y(dep_var):
	y_var = dep_var
	for n in y_ticks_node.get_children():
		n.queue_free()
	y_label_node.text = graph_settings[dep_var][0]
	var c: Control = Control.new()
	c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	c.size_flags_stretch_ratio = 0.5
	
	for i in range(num_y_ticks - 1, -1, -1):
		var l: Label = tick_label_scene.instantiate()
		l.text = str(graph_settings[dep_var][1][i])
		y_ticks_node.add_child(l)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.size_flags_vertical = Control.SIZE_EXPAND_FILL

	y_ticks_node.add_child(c)
	
	y_scale = graph_settings[dep_var][2]
	line.default_color = graph_settings[dep_var][3]
	update_graph()

func update_graph():
	if y_var in graph_settings.keys():
		var last = Vector2(0, size.y)
		var x_scale_factor = 0.5 / x_scale * size.x * 2/float(2*num_x_ticks+1)
		var y_scale_factor = size.y * 2/float(2*num_y_ticks+1) / y_scale
		line.clear_points()
		for i in range(len(sim.data[y_var])):
			var new = Vector2(sim.data["Time"][i] * x_scale_factor, size.y - sim.data[y_var][i] * y_scale_factor)
			line.add_point(new)
