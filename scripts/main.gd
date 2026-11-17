extends Node2D

func _ready() -> void:
	_ensure_input()
	_move_to_second_screen()
	_log_joypads()
	_fade_in()

func _log_joypads() -> void:
	var pads := Input.get_connected_joypads()
	if pads.is_empty():
		print("[input] геймпад не найден (клавиатура активна)")
		return
	for id in pads:
		print("[input] геймпад %d: %s" % [id, Input.get_joy_name(id)])

## Игра всегда стартует на втором мониторе, если он есть.
func _move_to_second_screen() -> void:
	var primary := DisplayServer.get_primary_screen()
	var target := -1
	for i in DisplayServer.get_screen_count():
		if i != primary:
			target = i
			break
	if target < 0:
		return
	var screen_pos := DisplayServer.screen_get_position(target)
	var screen_size := DisplayServer.screen_get_size(target)
	var deco := DisplayServer.window_get_size_with_decorations()
	# по горизонтали центрируем, по вертикали прижимаем к верху:
	# окно 1440x810 + рамка выше 840px монитора, центрирование обрезало бы заголовок
	var want := Vector2i(screen_pos.x + (screen_size.x - deco.x) / 2, screen_pos.y)

	# window_set_position ставит клиентскую область, а рамка уезжает вверх.
	# Ставим, смотрим где реально оказалась рамка, и корректируем.
	DisplayServer.window_set_position(want)
	var got := DisplayServer.window_get_position_with_decorations()
	var frame_offset := got - want
	if frame_offset != Vector2i.ZERO:
		DisplayServer.window_set_position(want - frame_offset)

func _ensure_input() -> void:
	var defs := {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"jump": [KEY_SPACE, KEY_W, KEY_UP],
		"listen": [KEY_E],
		"restart": [KEY_R],
	}
	for action: String in defs:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key: Key in defs[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)

func _fade_in() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)

	var rect := ColorRect.new()
	rect.color = Color(0, 0, 0, 1)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.size = get_viewport().get_visible_rect().size
	layer.add_child(rect)

	var tw := create_tween()
	tw.tween_property(rect, "color:a", 0.0, 1.1).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(layer.queue_free)