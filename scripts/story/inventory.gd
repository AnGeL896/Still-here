extends Node

## Простой инвентарь. id -> количество.
## Живёт в автолоаде, переживает смену сцен.
## Сохраняется вместе с Story в user://story.json.

signal changed

## Запасные названия для предметов, которые выдаются не через PickupItem.
const DEFAULT_NAMES := {
	"fuse": "Предохранитель",
}

var items: Dictionary = {}
## Что игрок вообще держал в руках — для HUD (показывать счётчик только после первого подбора)
var seen: Dictionary = {}
## id -> название (заполняется при подборе, живёт в сохранении)
var names: Dictionary = {}

func _ready() -> void:
	# Story грузится раньше и, если не успел, отдаёт инвентарь здесь
	var story := get_node_or_null("/root/Story")
	if story and story.has_method("take_pending_inventory"):
		var pending = story.call("take_pending_inventory")
		if pending is Dictionary and not pending.is_empty():
			apply_state(pending, false)

func add(id: String, count := 1, display_name := "") -> void:
	if id == "":
		return
	items[id] = int(items.get(id, 0)) + count
	seen[id] = true
	if display_name != "":
		names[id] = display_name
	changed.emit()
	_persist()

func has_seen(id: String) -> bool:
	return seen.has(id)

func has(id: String) -> bool:
	return int(items.get(id, 0)) > 0

func count(id: String) -> int:
	return int(items.get(id, 0))

func take(id: String, count := 1) -> bool:
	if not has(id):
		return false
	var left := int(items.get(id, 0)) - count
	if left <= 0:
		items.erase(id)
	else:
		items[id] = left
	changed.emit()
	_persist()
	return true

func clear() -> void:
	items.clear()
	seen.clear()
	names.clear()
	changed.emit()
	_persist()

func list() -> Array:
	var out: Array = []
	for k in items:
		out.append({"id": k, "count": int(items[k])})
	return out

## Отображаемое название: сохранённое при подборе, иначе запасное, иначе сам id.
func get_display_name(id: String) -> String:
	if names.has(id):
		return str(names[id])
	if DEFAULT_NAMES.has(id):
		return str(DEFAULT_NAMES[id])
	return id

func to_dict() -> Dictionary:
	return {
		"items": items.duplicate(),
		"seen": seen.duplicate(),
		"names": names.duplicate(),
	}

## Полная замена состояния (загрузка сохранения), без дублей.
func apply_state(data: Dictionary, persist := true) -> void:
	var it = data.get("items", {})
	items = (it as Dictionary).duplicate() if it is Dictionary else {}
	var sn = data.get("seen", {})
	seen = (sn as Dictionary).duplicate() if sn is Dictionary else {}
	var nm = data.get("names", {})
	names = (nm as Dictionary).duplicate() if nm is Dictionary else {}

	# JSON отдаёт числа как float — приводим к int
	for k in items.keys():
		items[k] = int(items[k])

	changed.emit()
	if persist:
		_persist()

func _persist() -> void:
	if not is_inside_tree():
		return
	var story := get_node_or_null("/root/Story")
	if story and story.has_method("save_state"):
		story.call("save_state")