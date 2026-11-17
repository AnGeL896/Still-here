extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)

	for i in 5:
		await process_frame

	print("экранов: ", DisplayServer.get_screen_count(), "  основной: ", DisplayServer.get_primary_screen())
	for i in DisplayServer.get_screen_count():
		print("  экран %d: pos=%s size=%s" % [i, DisplayServer.screen_get_position(i), DisplayServer.screen_get_size(i)])
	print("окно: ", DisplayServer.window_get_position(), " размер ", DisplayServer.window_get_size())

	print("--- геймпад в InputMap ---")
	for action in ["move_left", "move_right", "jump", "listen", "restart"]:
		var kinds: Array[String] = []
		for ev in InputMap.action_get_events(action):
			if ev is InputEventJoypadButton:
				kinds.append("кнопка %d" % ev.button_index)
			elif ev is InputEventJoypadMotion:
				kinds.append("ось %d = %.1f" % [ev.axis, ev.axis_value])
		print("  %-12s %s" % [action, ", ".join(kinds)])

	quit()