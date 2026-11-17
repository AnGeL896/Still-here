extends Node

## Состояние сюжета: флаги, прочитанные записки, глава.
## Пишется в user://story.json

const SAVE_PATH := "user://story.json"

var flags: Dictionary = {}
var notes_read: Dictionary = {}
var chapter := 1

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

func reset() -> void:
	flags.clear()
	notes_read.clear()
	chapter = 1
	save_state()

func save_state() -> void:
	var data := {
		"flags": flags,
		"notes": notes_read,
		"chapter": chapter,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()

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
	chapter = int(parsed.get("chapter", 1))