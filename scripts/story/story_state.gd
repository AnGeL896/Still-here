extends Node

## Состояние сюжета: флаги, прочитанные записки, глава.
## Пишется в user://story.json

const SAVE_PATH := "user://story.json"

var flags: Dictionary = {}
var notes_read: Dictionary = {}
## Числовые значения (слоты щитка и прочее)
var values: Dictionary = {}
var chapter := 1

## Инвентарь из файла, если Inventory ещё не создан (порядок автолоадов)
var pending_inventory: Dictionary = {}

signal flag_changed(key: String)
signal note_read(id: String)

func _ready() -> void:
	load_state()

func set_flag(key: String, value := true) -> void:
	if bool(flags.get(key, false)) == value:
		return
	flags[key] = value
	flag_changed.emit(key)
	save_state()

func has_flag(key: String) -> bool:
	return bool(flags.get(key, false))

func mark_note_read(id: String) -> void:
	if id == "" or notes_read.has(id):
		return
	notes_read[id] = true
	note_read.emit(id)
	save_state()

func is_note_read(id: String) -> bool:
	return bool(notes_read.get(id, false))

func set_value(key: String, v) -> void:
	values[key] = v
	save_state()

func get_value(key: String, def = 0):
	return values.get(key, def)

func reset() -> void:
	flags.clear()
	notes_read.clear()
	values.clear()
	pending_inventory.clear()
	chapter = 1
	save_state()

func save_state() -> void:
	var inv: Node = get_node_or_null("/root/Inventory") if is_inside_tree() else null
	var inv_data: Dictionary = inv.call("to_dict") if inv != null else {}
	var data := {
		"flags": flags,
		"notes": notes_read,
		"values": values,
		"chapter": chapter,
		"inventory": inv_data,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()

## Забирает инвентарь, прочитанный из файла (вызывает Inventory при старте).
func take_pending_inventory() -> Dictionary:
	var d := pending_inventory
	pending_inventory = {}
	return d

func load_state() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	flags = parsed.get("flags", {})
	notes_read = parsed.get("notes", {})
	values = parsed.get("values", {})
	chapter = int(parsed.get("chapter", 1))

	var pi = parsed.get("inventory", {})
	pending_inventory = pi if pi is Dictionary else {}
	if not pending_inventory.is_empty():
		var inv := get_node_or_null("/root/Inventory")
		if inv != null and inv.has_method("apply_state"):
			inv.call("apply_state", pending_inventory, false)
			pending_inventory = {}