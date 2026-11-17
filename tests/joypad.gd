extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	for i in 5:
		await process_frame

	var pads := Input.get_connected_joypads()
	print("подключённые геймпады: ", pads)
	for id in pads:
		print("  id=%d  имя='%s'" % [id, Input.get_joy_name(id)])

	print("--- привязки ---")
	for action in ["move_left", "move_right", "jump", "listen", "restart"]:
		var joy := 0
		var labels: Array[String] = []
		for ev in InputMap.action_get_events(action):
			if ev is InputEventJoypadButton:
				joy += 1
				labels.append("кнопка %d" % ev.button_index)
			elif ev is InputEventJoypadMotion:
				joy += 1
				labels.append("ось %d=%+.1f" % [ev.axis, ev.axis_value])
		print("  %-12s геймпадов: %d  (%s)" % [action, joy, ", ".join(labels)])

	quit()