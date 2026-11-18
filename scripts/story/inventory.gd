extends Node

## Простой инвентарь. id -> количество.
## Живёт в автолоаде, переживает смену сцен.

signal changed

var items: Dictionary = {}
## Что игрок вообще держал в руках — для HUD (показывать счётчик только после первого подбора)
var seen: Dictionary = {}

func add(id: String, count := 1) -> void:
	if id == "":
		return
	items[id] = int(items.get(id, 0)) + count
	seen[id] = true
	changed.emit()

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
	return true

func clear() -> void:
	items.clear()
	changed.emit()

func list() -> Array:
	var out: Array = []
	for k in items:
		out.append({"id": k, "count": int(items[k])})
	return out