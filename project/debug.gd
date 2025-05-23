extends VBoxContainer

var sim_node: Simulation
var in_node: TextEdit
var last_node: Label
var out_node: Label
var history = []
var history_idx = 0
var cont_button: CheckButton
var expression = Expression.new()


func _ready():
	sim_node = get_node("../../Simulation")
	in_node = get_node("In")
	last_node = get_node("Middle/Last")
	out_node = get_node("Out")
	cont_button = get_node("Middle/PanelContainer/VBoxContainer/CheckButton")

func _input(event):
	if event.is_action_pressed("ui_debug"):
		visible = !visible
		if visible:
			in_node.grab_focus()
		get_viewport().set_input_as_handled()
	
	if visible:		
		if event.is_action_pressed("ui_cancel"):
			visible = false
			get_viewport().set_input_as_handled()
			
		if event.is_action_pressed("ui_text_submit") and in_node.has_focus():
			parse()
			get_viewport().set_input_as_handled()
			
		if event.is_action_pressed("ui_up"):
			if history_idx > 0:
				history_idx -= 1
			in_node.text = history[history_idx]
		
		if event.is_action_pressed("ui_debug_toggle_cont"):
			cont_button.button_pressed = !cont_button.button_pressed
			get_viewport().set_input_as_handled()

func _process(delta):
	if cont_button.button_pressed:
		run()

func run():
	out_node.text = str(expression.execute([], sim_node))

func parse():
	if in_node.text != "":
		last_node.text = in_node.text
		expression.parse(last_node.text)
		run()
		history.append(in_node.text)
		history_idx = len(history)
		in_node.text = ""	
