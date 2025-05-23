extends VBoxContainer

var sim_node: Simulation
var in_node: TextEdit
var last_node: Label
var out_node: Label
var history = []
var history_idx = 0

func _ready():
	sim_node = get_node("../../Simulation")
	in_node = get_node("In")
	last_node = get_node("Last")
	out_node = get_node("Out")

func _input(event):
	if event.is_action_pressed("ui_debug"):
		visible = !visible
		if visible:
			in_node.grab_focus()
	
	if visible:		
		if in_node.has_focus():
			if event is InputEventKey and event.is_pressed():
				if OS.get_keycode_string(event.keycode) == "Enter":
					get_viewport().set_input_as_handled()
	
		if event.is_action_pressed("ui_accept"):
			var expression = Expression.new()
			last_node.text = in_node.text
			expression.parse(in_node.text)
			print(expression.execute([], sim_node))
			out_node.text = str(expression.execute([], sim_node))
			history.append(in_node.text)
			history_idx = len(history)
			in_node.text = ""
			
		if event.is_action_pressed("ui_up"):
			if history_idx > 0:
				history_idx -= 1
			in_node.text = history[history_idx]
			
