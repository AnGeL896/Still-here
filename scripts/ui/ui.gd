extends CanvasLayer

## Окно чтения записок. Подсказки убраны — только текст.

const VIEW := Vector2(480, 270)
const CHARS_PER_SEC := 62.0

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