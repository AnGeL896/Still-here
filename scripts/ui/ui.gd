extends CanvasLayer

## Окно чтения записок. Подсказки убраны — только текст.

const VIEW := Vector2(480, 270)
const CHARS_PER_SEC := 62.0
const FUSE_TOTAL := 3

var _hud: Label
var _prompt: Label
var _prompt_bg: ColorRect

var _safe: Node = null
var _safe_root: Control
var _digit_labels: Array[Label] = []
var _safe_msg: Label
var _safe_vals := [0, 0, 0]
var _safe_sel := 0

var _note_root: Control
var _title: Label
var _author: Label
var _body: Label
var _hint: Label
var _page_index: Label

var _note: NoteData
var _page := 0
var _shown := 0.0
var _typing := false
var _full := ""

func _ready() -> void:
	# 110 — выше постобработки (100)
	layer = 110
	_build_note()
	_build_hud()
	_build_prompt()
	_build_safe()

func _build_prompt() -> void:
	# подложка по ширине текста — читается на любом фоне
	_prompt_bg = ColorRect.new()
	_prompt_bg.color = Color(0.010, 0.014, 0.022, 0.55)
	_prompt_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prompt_bg.visible = false
	add_child(_prompt_bg)

	_prompt = Label.new()
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.position = Vector2(0, 240)
	_prompt.size = Vector2(VIEW.x, 18)
	_prompt.add_theme_font_override("font", _font())
	_prompt.add_theme_font_size_override("font_size", 9)
	_prompt.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82))
	_prompt.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	_prompt.add_theme_constant_override("shadow_offset_x", 1)
	_prompt.add_theme_constant_override("shadow_offset_y", 1)
	_prompt.visible = false
	add_child(_prompt)

func show_prompt(text: String) -> void:
	if _prompt == null or _note_root.visible:
		return
	# пустая строка = квадратик-пустышка, лучше скрыть
	if text.strip_edges() == "":
		hide_prompt()
		return
	_prompt.text = text
	_prompt.visible = true

	if _prompt_bg:
		var f := _prompt.get_theme_font("font")
		var w := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x
		_prompt_bg.size = Vector2(w + 14.0, 22.0)
		_prompt_bg.position = Vector2((VIEW.x - _prompt_bg.size.x) * 0.5, 238.0)
		_prompt_bg.visible = true

func hide_prompt() -> void:
	if _prompt:
		_prompt.visible = false
	if _prompt_bg:
		_prompt_bg.visible = false

# ─── сейф ─────────────────────────────────────────────────────

func _build_safe() -> void:
	_safe_root = Control.new()
	_safe_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_safe_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_safe_root.visible = false
	add_child(_safe_root)

	var dim := ColorRect.new()
	dim.color = Color(0.008, 0.010, 0.015, 0.86)
	dim.position = Vector2.ZERO
	dim.size = VIEW
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_safe_root.add_child(dim)

	var panel := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.070, 0.076, 0.090, 0.98)
	sb.border_color = Color(0.44, 0.40, 0.31, 0.9)
	sb.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", sb)
	panel.position = Vector2(130, 62)
	panel.size = Vector2(220, 146)
	_safe_root.add_child(panel)

	var title := Label.new()
	title.text = "СЕЙФ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(130, 70)
	title.size = Vector2(220, 18)
	title.add_theme_font_override("font", _font())
	title.add_theme_font_size_override("font_size", 10)
	title.add_theme_color_override("font_color", Color(0.95, 0.89, 0.73))
	_safe_root.add_child(title)

	for i in 3:
		var d := Label.new()
		d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		d.position = Vector2(148 + i * 64, 94)
		d.size = Vector2(48, 40)
		d.add_theme_font_override("font", _font())
		d.add_theme_font_size_override("font_size", 24)
		_safe_root.add_child(d)
		_digit_labels.append(d)

	_safe_msg = Label.new()
	_safe_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_safe_msg.position = Vector2(130, 140)
	_safe_msg.size = Vector2(220, 16)
	_safe_msg.add_theme_font_override("font", _font())
	_safe_msg.add_theme_font_size_override("font_size", 8)
	_safe_root.add_child(_safe_msg)

	var hint := Label.new()
	hint.text = "← → выбор     ↑ ↓ цифра     E — открыть     Esc — отойти"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(40, 188)
	hint.size = Vector2(400, 14)
	hint.add_theme_font_override("font", _font())
	hint.add_theme_font_size_override("font_size", 7)
	hint.add_theme_color_override("font_color", Color(0.48, 0.46, 0.40))
	_safe_root.add_child(hint)

func show_safe(safe: Node) -> void:
	_safe = safe
	_safe_vals = [0, 0, 0]
	_safe_sel = 0
	_safe_msg.text = ""
	_safe_root.visible = true
	_refresh_safe()
	hide_prompt()
	var p := get_tree().get_first_node_in_group("player")
	if p:
		p.call("set_frozen", true)

func _refresh_safe() -> void:
	for i in _digit_labels.size():
		_digit_labels[i].text = str(_safe_vals[i])
		var sel := i == _safe_sel
		_digit_labels[i].add_theme_color_override("font_color",
			Color(0.98, 0.90, 0.58) if sel else Color(0.52, 0.50, 0.44))

func _confirm_safe() -> void:
	var candidate := "%d%d%d" % [_safe_vals[0], _safe_vals[1], _safe_vals[2]]
	if _safe != null and bool(_safe.call("try_code", candidate)):
		_safe_msg.text = "ОТКРЫТО"
		_safe_msg.add_theme_color_override("font_color", Color(0.42, 0.95, 0.62))
		await get_tree().create_timer(0.8).timeout
		_close_safe()
	else:
		_safe_msg.text = "НЕ ПОДХОДИТ"
		_safe_msg.add_theme_color_override("font_color", Color(0.88, 0.32, 0.26))

func _close_safe() -> void:
	_safe_root.visible = false
	_safe = null
	var p := get_tree().get_first_node_in_group("player")
	if p:
		p.call("set_frozen", false)

func _input_safe(event: InputEvent) -> bool:
	var handled := false
	if event.is_action_pressed("ui_cancel"):
		_close_safe()
		handled = true
	elif event.is_action_pressed("move_left"):
		_safe_sel = (_safe_sel + 2) % 3
		_refresh_safe()
		handled = true
	elif event.is_action_pressed("move_right"):
		_safe_sel = (_safe_sel + 1) % 3
		_refresh_safe()
		handled = true
	elif event.is_action_pressed("ui_up"):
		_safe_vals[_safe_sel] = (_safe_vals[_safe_sel] + 1) % 10
		_refresh_safe()
		handled = true
	elif event.is_action_pressed("ui_down"):
		_safe_vals[_safe_sel] = (_safe_vals[_safe_sel] + 9) % 10
		_refresh_safe()
		handled = true
	elif event.is_action_pressed("interact"):
		_confirm_safe()
		handled = true
	return handled

func _build_hud() -> void:
	_hud = Label.new()
	_hud.position = Vector2(8, 6)
	_hud.add_theme_font_override("font", _font())
	_hud.add_theme_font_size_override("font_size", 8)
	_hud.add_theme_color_override("font_color", Color(0.92, 0.87, 0.74))
	_hud.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.92))
	_hud.add_theme_constant_override("shadow_offset_x", 1)
	_hud.add_theme_constant_override("shadow_offset_y", 1)
	_hud.visible = false
	add_child(_hud)

## Счётчик появляется только после первого подобранного предохранителя.
func _update_hud() -> void:
	if _hud == null:
		return
	if not Inventory.has_seen("fuse"):
		_hud.visible = false
		return
	_hud.visible = true

	var carried: int = Inventory.count("fuse")
	var inserted := 0
	for n in get_tree().get_nodes_in_group("power_source"):
		inserted = maxi(inserted, int(n.call("get_slots")))
	_hud.text = "Предохранители   %d / %d" % [carried + inserted, FUSE_TOTAL]

func _font() -> SystemFont:
	var f := SystemFont.new()
	f.font_names = PackedStringArray(["Segoe UI", "Calibri", "Arial", "DejaVu Sans"])
	f.font_weight = 400
	return f

func _build_note() -> void:
	_note_root = Control.new()
	_note_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_note_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_note_root.visible = false
	add_child(_note_root)

	var dim := ColorRect.new()
	dim.color = Color(0.008, 0.010, 0.015, 0.88)
	dim.position = Vector2.ZERO
	dim.size = VIEW
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_note_root.add_child(dim)

	var panel := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.070, 0.076, 0.090, 0.98)
	sb.border_color = Color(0.44, 0.40, 0.31, 0.9)
	sb.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", sb)
	panel.position = Vector2(52, 28)
	panel.size = Vector2(376, 214)
	_note_root.add_child(panel)

	_title = Label.new()
	_title.position = Vector2(66, 40)
	_title.size = Vector2(348, 18)
	_title.add_theme_font_override("font", _font())
	_title.add_theme_font_size_override("font_size", 12)
	_title.add_theme_color_override("font_color", Color(0.95, 0.89, 0.73))
	_note_root.add_child(_title)

	_author = Label.new()
	_author.position = Vector2(66, 59)
	_author.size = Vector2(348, 13)
	_author.add_theme_font_override("font", _font())
	_author.add_theme_font_size_override("font_size", 8)
	_author.add_theme_color_override("font_color", Color(0.55, 0.52, 0.45))
	_note_root.add_child(_author)

	var sep := ColorRect.new()
	sep.color = Color(0.44, 0.40, 0.31, 0.45)
	sep.position = Vector2(66, 76)
	sep.size = Vector2(348, 1)
	_note_root.add_child(sep)

	_body = Label.new()
	_body.position = Vector2(66, 86)
	_body.size = Vector2(348, 116)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_body.add_theme_font_override("font", _font())
	_body.add_theme_font_size_override("font_size", 9)
	_body.add_theme_color_override("font_color", Color(0.87, 0.85, 0.79))
	_note_root.add_child(_body)

	_page_index = Label.new()
	_page_index.position = Vector2(66, 220)
	_page_index.size = Vector2(120, 12)
	_page_index.add_theme_font_override("font", _font())
	_page_index.add_theme_font_size_override("font_size", 7)
	_page_index.add_theme_color_override("font_color", Color(0.40, 0.38, 0.33))
	_note_root.add_child(_page_index)

	_hint = Label.new()
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hint.position = Vector2(230, 220)
	_hint.size = Vector2(184, 12)
	_hint.add_theme_font_override("font", _font())
	_hint.add_theme_font_size_override("font_size", 7)
	_hint.add_theme_color_override("font_color", Color(0.52, 0.49, 0.42))
	_note_root.add_child(_hint)

# ─── чтение ───────────────────────────────────────────────────

func show_note(note: NoteData) -> void:
	if note == null:
		return
	_note = note
	_page = 0
	_note_root.visible = true
	var p := get_tree().get_first_node_in_group("player")
	if p:
		p.call("set_frozen", true)
	_refresh_page()

func _refresh_page() -> void:
	_title.text = _note.title
	_author.text = _note.author
	_full = _note.pages[_page] if _page < _note.pages.size() else ""
	_body.text = _full
	_body.visible_characters = 0
	_shown = 0.0
	_typing = true
	_page_index.text = "%d / %d" % [_page + 1, _note.pages.size()]
	_hint.text = "E — пропустить"

func _process(delta: float) -> void:
	_update_hud()
	if not _typing:
		return
	_shown += delta * CHARS_PER_SEC
	var n := int(_shown)
	if n >= _full.length():
		n = _full.length()
		_typing = false
		_hint.text = _next_hint()
	_body.visible_characters = n

func _next_hint() -> String:
	if _page + 1 < _note.pages.size():
		return "E — далее      Esc — закрыть"
	return "Esc — закрыть"

func _input(event: InputEvent) -> void:
	# пауза перехватывает всё
	if PauseMenu.is_open():
		return

	if _safe != null and _safe_root.visible:
		if _input_safe(event):
			get_viewport().set_input_as_handled()
		return

	if _note == null or not _note_root.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("jump"):
		if _typing:
			_typing = false
			_body.visible_characters = -1
			_hint.text = _next_hint()
		elif _page + 1 < _note.pages.size():
			_page += 1
			_refresh_page()
		else:
			_close()
		get_viewport().set_input_as_handled()

func _close() -> void:
	_note_root.visible = false
	_note = null
	_typing = false
	var p := get_tree().get_first_node_in_group("player")
	if p:
		p.call("set_frozen", false)

func is_note_open() -> bool:
	return _note != null and _note_root.visible

func is_safe_open() -> bool:
	return _safe != null and _safe_root.visible