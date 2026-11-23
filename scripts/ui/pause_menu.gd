extends CanvasLayer

## Пауза по ESC. Затемнение + опции: продолжить / начать заново / выход.

const VIEW := Vector2(480, 270)

var _root: Control
var _sel := 0
var _options := ["Продолжить", "Начать заново", "Выйти"]
var _labels: Array[Label] = []
var _hint: Label

func _ready() -> void:
	layer = 130  # выше SceneFlow (120)
	# работаем даже когда игра на паузе
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()

func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.visible = false
	add_child(_root)

	# затемнение
	var dim := ColorRect.new()
	dim.color = Color(0.008, 0.010, 0.015, 0.88)
	dim.position = Vector2.ZERO
	dim.size = VIEW
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dim)

	# заголовок
	var title := Label.new()
	title.text = "ПАУЗА"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 52)
	title.size = Vector2(VIEW.x, 24)
	title.add_theme_font_override("font", _font())
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.95, 0.89, 0.73))
	_root.add_child(title)

	# опции
	for i in _options.size():
		var lbl := Label.new()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.position = Vector2(0, 92 + i * 26)
		lbl.size = Vector2(VIEW.x, 20)
		lbl.add_theme_font_override("font", _font())
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", Color(0.72, 0.70, 0.64))
		_root.add_child(lbl)
		_labels.append(lbl)

	# подсказка
	_hint = Label.new()
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.position = Vector2(0, 210)
	_hint.size = Vector2(VIEW.x, 14)
	_hint.add_theme_font_override("font", _font())
	_hint.add_theme_font_size_override("font_size", 8)
	_hint.add_theme_color_override("font_color", Color(0.40, 0.38, 0.33))
	_root.add_child(_hint)

	_refresh()

func _font() -> SystemFont:
	var f := SystemFont.new()
	f.font_names = PackedStringArray(["Segoe UI", "Calibri", "Arial", "DejaVu Sans"])
	f.font_weight = 400
	return f

func _refresh() -> void:
	for i in _labels.size():
		var sel := i == _sel
		_labels[i].add_theme_color_override("font_color",
			Color(0.98, 0.90, 0.58) if sel else Color(0.52, 0.50, 0.44))
		_labels[i].text = "> " + _options[i] + "  <" if sel else _options[i]

func is_open() -> bool:
	return _root != null and _root.visible

func toggle() -> void:
	if _root.visible:
		close()
	else:
		open()

func open() -> void:
	_root.visible = true
	_sel = 0
	_refresh()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# освобождаем UI для паузы
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.set_frozen(true)

func close() -> void:
	_root.visible = false
	get_tree().paused = false
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.set_frozen(false)

func _input(event: InputEvent) -> void:
	if not _root.visible:
		# ESC открывает паузу — только если UI не перехватил
		if event.is_action_pressed("pause") and not _ui_has_focus():
			open()
			get_viewport().set_input_as_handled()
		return

	# навигация
	if event.is_action_pressed("move_left") or event.is_action_pressed("ui_up"):
		_sel = (_sel - 1 + _options.size()) % _options.size()
		_refresh()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_right") or event.is_action_pressed("ui_down"):
		_sel = (_sel + 1) % _options.size()
		_refresh()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") or event.is_action_pressed("jump"):
		_activate()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func _activate() -> void:
	match _sel:
		0:
			close()
		1:
			close()
			Story.reset()
			Inventory.clear()
			SceneFlow.go_to("res://scenes/main.tscn", Vector2(80, 242))
		2:
			get_tree().quit()

func _ui_has_focus() -> bool:
	# если открыт сейф или заметка — ESC уйдёт им, а не паузы
	var ui := get_node_or_null("/root/UI")
	if ui == null:
		return false
	if ui.has_method("is_note_open") and ui.call("is_note_open"):
		return true
	if ui.has_method("is_safe_open") and ui.call("is_safe_open"):
		return true
	if ui.has_method("is_inventory_open") and ui.call("is_inventory_open"):
		return true
	return false