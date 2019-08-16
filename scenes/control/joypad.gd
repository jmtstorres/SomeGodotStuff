extends Control

export(Vector2) var right_input = Vector2()
export(Vector2) var left_input = Vector2()

func _on_left_stick_control_signal(speed, angle, vector):
	left_input = vector
	input_received(vector, 0)
	pass

func _on_right_stick_control_signal(speed, angle, vector):
	right_input = vector
	input_received(vector, 1)
	pass

func input_received(vector,id):
	#avoid too much input restraining entries with 0 value
	if vector.x != 0:
		#filter witch side has sent event
		match id:
			0:
				send_stick_event(vector.x, JOY_ANALOG_LX)
			1:
				send_stick_event(vector.x, JOY_ANALOG_RX)
	
	#same treatment but for Y axis
	if vector.y != 0:
		match id:
			0:
				send_stick_event(vector.y, JOY_ANALOG_LY)
			1:
				send_stick_event(vector.y, JOY_ANALOG_RY)
	pass

#TODO
func send_stick_event(value, id):
	var ev = InputEventJoypadMotion.new()
	ev.set_axis_value(value)
	ev.set_axis(id)
	Input.parse_input_event(ev)
	pass

