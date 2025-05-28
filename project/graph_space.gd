class_name Grapher
extends Control

var sim: Simulation

var x_ticks_node: HBoxContainer
var y_ticks_node: VBoxContainer
var y_ticks_node2: VBoxContainer

var v_select_container: HBoxContainer
var y_label_node: Label
var y_label_node2: Label

var lines: Dictionary
var full_ui: Control

var shown_vars = []
var shown_percent_vars = []
var shown_log_vars = []

const num_x_ticks = 12
const num_y_ticks = 10

const tick_length = 7

var x_scale = 4

var y_var: String

var graph_settings: Dictionary

var tick_label_scene: PackedScene = preload("res://tick_label.tscn")
var var_selector_scene: PackedScene = preload("res://graph_var_selector.tscn")

var percent_ticks
var log_ticks

var x_scale_factor

var debug: Control

var timer = 0
const min_y = 750
const max_y = 60

var open = false

func _ready():
	percent_ticks = range(10, 110, 10)
	log_ticks = range(1, 11)
	for i in len(log_ticks):
		log_ticks[i] = "10^%s" % log_ticks[i]
		
	graph_settings = {
		"Health": {
			"label": "Health (%)",
			"ticks": percent_ticks, 
			"yscale": 10, 
			"color": Color.LIME_GREEN
		},
		"Immune Activity": {
			"label": "Immune Activity (%)", 
			"ticks": percent_ticks, 
			"yscale": 10, 
			"color": Color.ORANGE
		},
		"Bacteria": {
			"label": "Bacteria (CFU)", 
			"ticks": log_ticks, 
			"yscale": 1, 
			"color": Color.DARK_GREEN
		},
		"Mirror Bacteria": {
			"label": "Mirror Bacteria (CFU)", 
			"ticks": log_ticks, 
			"yscale": 1, 
			"color": Color.DARK_BLUE
		}
	}
	x_scale_factor = size.x * 2.0/float(2*num_x_ticks+1) / x_scale
	for v in graph_settings.keys():
		lines[v] = GraphLine.new()
		lines[v].default_color = graph_settings[v]["color"]
		add_child(lines[v])
		lines[v].x_factor = 624 * 2/float(2*num_x_ticks+1) / x_scale
		lines[v].y_factor = 384 * 2/float(2*num_y_ticks+1) / graph_settings[v]["yscale"]
		lines[v].y_size = 384
	
	sim = get_tree().get_current_scene().get_node("Simulation")
	x_ticks_node = get_node("../XTicks")
	y_ticks_node = get_node("../YTicks")
	y_ticks_node2 = get_node("../YTicks2")
	v_select_container = get_node("../../Options")
	y_label_node = get_node("../YLabelControl/YLabel")
	y_label_node2 = get_node("../YLabelControl2/YLabel")
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

	for v in graph_settings.keys():
		var s: HBoxContainer = var_selector_scene.instantiate()
		s.get_node("Label").text = v + " "
		s.grapher = self
		v_select_container.add_child(s)
	
	for axis in [y_ticks_node, y_ticks_node2]:
		for i in range(num_y_ticks):
			var l: Label = tick_label_scene.instantiate()
			axis.add_child(l)
			l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			l.size_flags_vertical = Control.SIZE_EXPAND_FILL
		c = Control.new()
		axis.add_child(c)
		c.size_flags_vertical = Control.SIZE_EXPAND_FILL
		c.size_flags_stretch_ratio = 0.5
		
	debug = get_tree().get_current_scene().get_node("UI/Debug")
	
	full_ui.position.y = min_y

func _input(event):
	if event.is_action_pressed("ui_graph_toggle") and (open or !debug.visible):
		toggle_visible()

func toggle_visible():
		open = !open
		timer = 0.01 * (1 if open else -1)

func _process(delta):
	if abs(timer) == 0.5:
		return
	if timer == 0:
		return
	if timer > 0:
		timer += min(0.5 - timer, delta)
		full_ui.position.y = max_y + (min_y - max_y) * 4 * (0.5 - timer)**2
	else:
		timer -= min(abs(timer + 0.5), delta)
		full_ui.position.y = max_y + (min_y - max_y) * 4 * timer**2

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
	
	if len(shown_percent_vars) and len(shown_log_vars):
		draw_line(Vector2(size.x, 0), Vector2(size.x, size.y), Color.BLACK, 2.0)
		for t in range(num_y_ticks):
			var y = (t*2+1)/float(2*num_y_ticks + 1) * size.y
			draw_line(Vector2(size.x, y), Vector2(size.x + tick_length, y), Color.BLACK, 2)

func update_x(t: float):
	x_scale = int(ceil(1.1 * t / num_x_ticks))
	x_scale_factor = size.x * 2/float(2*num_x_ticks+1) / x_scale
	for l in lines.values():
		(l as GraphLine).set_x_factor(x_scale_factor)
	for i in range(1, num_x_ticks + 1):
		x_ticks_node.get_child(i).text = str(x_scale*i)
	

func clear_lines():
	for l in lines.values():
		(l as GraphLine).clear()

func update_y():
	shown_vars = []
	shown_percent_vars = []
	shown_log_vars = []
	
	y_label_node.text = ""
	y_label_node2.text = ""
	for b in v_select_container.get_children():
		var t = b.label.text.left(len(b.label.text) - 1)
		if b.button.button_pressed:
			shown_vars.append(t)
			if graph_settings[t]["ticks"] == percent_ticks:
				shown_percent_vars.append(t)
			else:
				shown_log_vars.append(t)

	for t in y_ticks_node2.get_children():
		if t is Label:
			t.text = ""

	if len(shown_percent_vars):
		for i in range(y_ticks_node.get_child_count() - 1):
			y_ticks_node.get_child(i).text = str(percent_ticks[num_y_ticks - i - 1])
		for v in shown_percent_vars:
			y_label_node.text += "%s, " % graph_settings[v]["label"]
		y_label_node.text = y_label_node.text.substr(0, len(y_label_node.text) - 2)
			
		if len(shown_log_vars):
			for i in range(y_ticks_node2.get_child_count() - 1):
				y_ticks_node2.get_child(i).text = str(log_ticks[num_y_ticks - i - 1])
			for v in shown_log_vars:
				y_label_node2.text += "%s, " % graph_settings[v]["label"]
			y_label_node2.text = y_label_node2.text.substr(0, len(y_label_node2.text) - 2)

	elif len(shown_log_vars):
		for i in range(y_ticks_node.get_child_count() - 1):
			y_ticks_node.get_child(i).text = str(log_ticks[num_y_ticks - i - 1])
		for v in shown_log_vars:
			y_label_node.text += "%s, " % graph_settings[v]["label"]
		y_label_node.text = y_label_node.text.substr(0, len(y_label_node.text) - 2)
	else:
		y_label_node.text = "Y-Axis (None)"
		for t in y_ticks_node.get_children():
			if t is Label:
				t.text = ""

	for v in lines.keys():
		lines[v].visible = v in shown_vars

	queue_redraw()
	update_graph()

func update_graph():
	var t = sim.data["Time"][-1]
	if t > num_x_ticks * x_scale * 0.95:
		update_x(t)
	for v in lines.keys():
		(lines[v] as GraphLine).add_datapoint(Vector2(t, sim.data[v][-1]))
