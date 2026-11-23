extends SceneTree

## Тест компактного инвентаря (TAB).
## Свой сейв: user://story.json читается в память и восстанавливается в конце.

const SAVE_PATH := "user://story.json"

var _backup := ""
var _backup_exists := false

func _initialize() -> void:
	_run()

func _backup_save() -> void:
	_backup_exists = FileAccess.file_exists(SAVE_PATH)
	if not _backup_exists:
		_backup = ""
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	_backup = f.get_as_text() if f else ""
	if f:
		f.close()

func _restore_save() -> void:
	if not _backup_exists:
		if FileAccess.file_exists(SAVE_PATH):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(_backup)
		f.close()

func _press_key(code: Key) -> void:
	var ev := InputEventKey.new()
	ev.keycode = code
	ev.physical_keycode = code
	ev.pressed = true
	Input.parse_input_event(ev)
	for i in 3:
		await process_frame

func _run() -> void:
	_backup_save()
	await process_frame

	var inv = root.get_node("Inventory")
	var story = root.get_node("Story")
	var ui = root.get_node("UI")
	var pause = root.get_node("PauseMenu")

	story.call("reset")
	inv.call("clear")

	var room: Node = load("res://scenes/interiors/room_apt4.tscn").instantiate()
	root.add_child(room)
	for i in 10:
		await physics_frame

	var p = room.get_node("Player")
	var panel = ui.get_node("InventoryOverlay")

	print("=== 1. TAB открывает ===")
	await _press_key(KEY_TAB)
	print("  open=", panel.call("is_open"), " visible=", panel.visible)

	print("=== 2. TAB закрывает ===")
	await _press_key(KEY_TAB)
	print("  open=", panel.call("is_open"))
	await _press_key(KEY_TAB)
	await _press_key(KEY_ESCAPE)
	print("  после ESC: open=", panel.call("is_open"), " pause=", pause.call("is_open"))

	print("=== 3. движение во время открытого ===")
	inv.call("add", "fuse", 1)
	inv.call("add", "key_roof", 1, "Ключ от крыши")
	await _press_key(KEY_TAB)
	var x0: float = p.global_position.x
	Input.action_press("move_right")
	for i in 30:
		await physics_frame
	Input.action_release("move_right")
	print("  x до=", x0, " после=", p.global_position.x, " frozen=", p.frozen)
	await _press_key(KEY_TAB)

	print("=== 4/5. записки ===")
	print("  до чтения пусто=", panel.call("get_entries").is_empty())
	var note = room.get_node("Table/Note")
	note.call("interact", p)
	for i in 3:
		await process_frame
	ui.call("_close")
	for i in 3:
		await process_frame
	print("  прочитана=", story.call("is_note_read", "apt4_note"))
	await _press_key(KEY_TAB)
	var notes: Array = panel.call("get_entries")
	print("  записей=", notes.size(), " id=", notes[0].id if notes.size() > 0 else "нет")

	print("=== 6. чтение из инвентаря ===")
	panel.call("_activate")
	for i in 3:
		await process_frame
	print("  окно открыто=", ui.call("is_note_open"), " id=", ui._note.id if ui._note else "нет")
	print("  страниц=", ui._note.pages.size() if ui._note else 0)
	for i in 5:
		var ev := InputEventAction.new()
		ev.action = "interact"
		ev.pressed = true
		ui.call("_input", ev)
		for j in 2:
			await process_frame
	print("  дошли до страницы=", ui._page + 1, " окно открыто=", ui.call("is_note_open"))
	ui.call("_close")
	for i in 2:
		await process_frame

	print("=== 7. ключи ===")
	panel.call("_switch_cat", 1)
	var keys: Array = panel.call("get_entries")
	print("  ключей=", keys.size(), " первый=", keys[0].title if keys.size() > 0 else "нет")

	print("=== 8/9. предметы и щиток ===")
	inv.call("add", "fuse", 2)
	panel.call("_switch_cat", 1)
	var items: Array = panel.call("get_entries")
	print("  предметы=", items.size(), " fuse=", inv.count("fuse"))
	var box = room.get_node("FuseBox")
	for i in 3:
		box.call("interact", null)
		for j in 2:
			await process_frame
	print("  fuse после щитка=", inv.count("fuse"), " powered=", box.call("is_powered"))
	panel.call("_refresh")
	print("  пусто в предметах=", panel.call("get_entries").is_empty())

	print("=== 10/11. сохранение и загрузка ===")
	inv.call("add", "key_playground", 1, "Ржавый ключ")
	inv.call("add", "fuse", 1)
	story.call("save_state")
	inv.call("apply_state", {}, false)
	print("  память очищена: ", inv.count("fuse"), " ", inv.count("key_playground"))
	story.call("load_state")
	print("  после load: fuse=", inv.count("fuse"), " playground=", inv.count("key_playground"),
		" имя=", inv.call("get_display_name", "key_playground"))
	story.call("load_state")
	story.call("load_state")
	print("  после 3 load (без дублей): fuse=", inv.count("fuse"), " playground=", inv.count("key_playground"))

	print("=== 12. возврат управления ===")
	await _press_key(KEY_TAB)
	print("  open=", panel.call("is_open"), " frozen=", p.frozen)
	await _press_key(KEY_ESCAPE)
	print("  после ESC: open=", panel.call("is_open"), " frozen=", p.frozen)

	print("=== 13. конфликты ===")
	ui.call("show_note", load("res://data/notes/apt4_note.tres"))
	await _press_key(KEY_TAB)
	print("  TAB при открытой записке: инвентарь=", panel.call("is_open"))
	ui.call("_close")
	await _press_key(KEY_TAB)
	await _press_key(KEY_ESCAPE)
	print("  ESC закрыл инвентарь, пауза=", pause.call("is_open"), " инвентарь=", panel.call("is_open"))

	_restore_save()
	print("=== SAVE RESTORED ===")
	quit()