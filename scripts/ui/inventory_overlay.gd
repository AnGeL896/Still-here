extends Control

## Компактный инвентарь. TAB — открыть/закрыть, ESC — закрыть.
## Панель поверх мира: фон остаётся видимым, игрок замораживается.
## Категории: записки (Story), ключи (id с префиксом key_), предметы (остальное).

const VIEW := Vector2(480, 270)
const PANEL_SIZE := Vector2(304, 188)
const ROW_H := 22.0
const MAX_ROWS := 5
const CATS := ["Записки", "Ключи", "Предметы"]

const C_BG := Color(0.055, 0.062, 0.078, 0.94)
const C_BORDER := Color(0.44, 0.40, 0.31, 0.85)
const C_TEXT := Color(0.87, 0.85, 0.79)
const C_DIM := Color(0.52, 0.50, 0.44)
const C_ACCENT := Color(0.91, 0.71, 0.35)
const C_SEL := Color(0.98, 0.90, 0.58)

var _ui: Node
var _font: Font

var _panel: Panel
var _tabs: Array[Label] = []
var _tab_lines: Array[ColorRect] = []
var _rows: Array[Label] = []
var _counts: Array[Label] = []
var _marks: Array[ColorRect] = []
var _empty: Label

var _cat := 0
var _sel := [0, 0, 0]
var _open := false
var _tween: Tween
var _notes: Dictionary = {}
var _home := Vector2.ZERO

func _ready() -> void:
	_ui = get_parent()
	_font = _ui.call("_font") if _ui and _ui.has_method("_font") else null
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_build()

func is_open() -> bool:
	return _open

# ─── построение ───────────────────────────────────────────────

func _build() -> void:
	_panel = Panel.new()
	_panel.position = Vector2(VIEW.x - PANEL_SIZE.x - 12, 44)
	_panel.size = PANEL_SIZE
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = C_BG
	sb.border_color = C_BORDER
	sb.set_border_width_all(1)
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_left = 2
	sb.corner_radius_bottom_right = 2
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.55)
	sb.shadow_size = 6
	_panel.add_theme_stylebox_override("panel", sb)
	add_child(_panel)

	var title := Label.new()
	title.text = "ИНВЕНТАРЬ"
	title.position = Vector2(11, 8)
	title.size = Vector2(200, 14)
	title.add_theme_font_override("font", _font)
	title.add_theme_font_size_override("font_size", 10)
	title.add_theme_color_override("font_color", C_SEL)
	_panel.add_child(title)

	# тонкая тёплая черта под заголовком
	var rule := ColorRect.new()
	rule.color = Color(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 0.30)
	rule.position = Vector2(11, 23)
	rule.size = Vector2(PANEL_SIZE.x - 22, 1)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(rule)

	for i in CATS.size():
		var t := Label.new()
		t.text = CATS[i]
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		t.position = Vector2(8 + i * 96, 28)
		t.size = Vector2(94, 14)
		t.add_theme_font_override("font", _font)
		t.add_theme_font_size_override("font_size", 8)
		t.add_theme_color_override("font_color", C_DIM)
		_panel.add_child(t)
		_tabs.append(t)

		var line := ColorRect.new()
		line.color = Color(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 0.0)
		line.position = Vector2(8 + i * 96, 43)
		line.size = Vector2(94, 1)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_panel.add_child(line)
		_tab_lines.append(line)

	for i in MAX_ROWS:
		var y := 52.0 + i * ROW_H

		var mark := ColorRect.new()
		mark.color = Color(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 0.0)
		mark.position = Vector2(9, y + 5)
		mark.size = Vector2(2, 11)
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_panel.add_child(mark)
		_marks.append(mark)

		var r := Label.new()
		r.position = Vector2(17, y + 2)
		r.size = Vector2(228, 16)
		r.add_theme_font_override("font", _font)
		r.add_theme_font_size_override("font_size", 9)
		r.add_theme_color_override("font_color", C_TEXT)
		r.clip_text = true
		_panel.add_child(r)
		_rows.append(r)

		var c := Label.new()
		c.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		c.position = Vector2(246, y + 3)
		c.size = Vector2(46, 14)
		c.add_theme_font_override("font", _font)
		c.add_theme_font_size_override("font_size", 8)
		c.add_theme_color_override("font_color", C_DIM)
		_panel.add_child(c)
		_counts.append(c)

	_empty = Label.new()
	_empty.text = "пусто"
	_empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty.position = Vector2(8, 92)
	_empty.size = Vector2(PANEL_SIZE.x - 16, 16)
	_empty.add_theme_font_override("font", _font)
	_empty.add_theme_font_size_override("font_size", 9)
	_empty.add_theme_color_override("font_color", C_DIM)
	_panel.add_child(_empty)

	var hint := Label.new()
	hint.text = "A/D — раздел    ↑/↓ — выбор    E — открыть    TAB — закрыть"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(4, PANEL_SIZE.y - 17)
	hint.size = Vector2(PANEL_SIZE.x - 8, 12)
	hint.add_theme_font_override("font", _font)
	hint.add_theme_font_size_override("font_size", 7)
	hint.add_theme_color_override("font_color", Color(0.40, 0.38, 0.33))
	_panel.add_child(hint)

	_home = _panel.position

# ─── состояние ────────────────────────────────────────────────

func _scan_notes() -> void:
	if not _notes.is_empty():
		return
	var dir := DirAccess.open("res://data/notes")
	if dir == null:
		return
	var files := dir.get_files()
	files.sort()
	for f in files:
		if not str(f).ends_with(".tres"):
			continue
		var note_res = load("res://data/notes/" + str(f))
		if note_res is NoteData and str(note_res.id) != "":
			_notes[note_res.id] = note_res

func get_entries() -> Array:
	var out: Array = []
	if _cat == 0:
		var ids := Story.notes_read.keys()
		ids.sort()
		for id in ids:
			if _notes.has(id):
				var n: NoteData = _notes[id]
				out.append({"kind": "note", "id": str(id), "title": str(n.title), "count": ""})
	elif _cat == 1:
		for id in Inventory.items.keys():
			if str(id).begins_with("key_") and int(Inventory.items[id]) > 0:
				out.append({"kind": "key", "id": str(id), "title": Inventory.get_display_name(id), "count": ""})
	else:
		for id in Inventory.items.keys():
			if not str(id).begins_with("key_") and int(Inventory.items[id]) > 0:
				out.append({"kind": "item", "id": str(id), "title": Inventory.get_display_name(id),
					"count": "×%d" % int(Inventory.items[id])})
	if _cat != 0:
		out.sort_custom(func(a, b): return str(a.title) < str(b.title))
	return out

func _refresh() -> void:
	var entries := get_entries()
	var top := entries.size() - 1
	_sel[_cat] = clampi(_sel[_cat], 0, maxi(top, 0))

	for i in MAX_ROWS:
		var has := i < entries.size()
		_rows[i].visible = has
		_counts[i].visible = has and str(entries[i].count) != ""
		_marks[i].visible = has and i == _sel[_cat]
		if has:
			_rows[i].text = str(entries[i].title)
			_counts[i].text = str(entries[i].count)
			_rows[i].add_theme_color_override("font_color", C_SEL if i == _sel[_cat] else C_TEXT)

	_empty.visible = entries.is_empty()

	for i in CATS.size():
		var active := i == _cat
		_tabs[i].add_theme_color_override("font_color", C_SEL if active else C_DIM)
		_tab_lines[i].color = Color(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 0.75 if active else 0.0)

func _freeze(v: bool) -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p and p.has_method("set_frozen"):
		p.call("set_frozen", v)

func _can_open() -> bool:
	if PauseMenu != null and PauseMenu.is_open():
		return false
	if SceneFlow != null and SceneFlow.is_busy():
		return false
	if _ui:
		if _ui.call("is_note_open"):
			return false
		if _ui.call("is_safe_open"):
			return false
	return true

# ─── открытие / закрытие ──────────────────────────────────────

func open_inventory() -> void:
	if _open or not _can_open():
		return
	_scan_notes()
	_open = true
	visible = true
	_refresh()

	_panel.modulate.a = 0.0
	_panel.position = _home + Vector2(10, 0)
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_panel, "modulate:a", 1.0, 0.15)
	_tween.tween_property(_panel, "position:x", _home.x, 0.15) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	_freeze(true)
	if _ui and _ui.has_method("hide_prompt"):
		_ui.call("hide_prompt")

func close_inventory(instant := false) -> void:
	if not _open:
		return
	_open = false
	if _tween and _tween.is_running():
		_tween.kill()
	if instant:
		visible = false
		_panel.modulate.a = 1.0
		_panel.position = _home
	else:
		_tween = create_tween()
		_tween.tween_property(_panel, "modulate:a", 0.0, 0.12)
		_tween.tween_callback(_on_closed)
	_freeze(false)

func _on_closed() -> void:
	if not _open:
		visible = false
		_panel.position = _home

# ─── ввод ─────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if not _open:
		if event.is_action_pressed("toggle_inventory"):
			open_inventory()
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("toggle_inventory") or event.is_action_pressed("ui_cancel"):
		close_inventory()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_left"):
		_switch_cat(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_right"):
		_switch_cat(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_move_sel(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		_move_sel(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_activate()
		get_viewport().set_input_as_handled()

func _switch_cat(dir: int) -> void:
	_cat = (_cat + dir + CATS.size()) % CATS.size()
	_refresh()

func _move_sel(dir: int) -> void:
	var n := get_entries().size()
	if n == 0:
		return
	_sel[_cat] = (_sel[_cat] + dir + n) % n
	_refresh()

func _activate() -> void:
	var entries := get_entries()
	if entries.is_empty():
		return
	var i := clampi(_sel[_cat], 0, entries.size() - 1)
	var e: Dictionary = entries[i]
	if str(e.kind) == "note" and _notes.has(e.id):
		var note: NoteData = _notes[e.id]
		close_inventory(true)
		if _ui and _ui.has_method("show_note"):
			_ui.call("show_note", note)