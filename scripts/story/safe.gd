extends Interactable
class_name Safe

## Сейф с кодовым замком. Код лежит в записке.

@export var code := "471"
@export var loot_item_id := "fuse"
@export var loot_count := 1
## Уникальный ключ сохранения. Пусто = имя узла.
@export var safe_id := ""

var _opened := false
var _door: Polygon2D

func _ready() -> void:
	super._ready()
	if safe_id == "":
		safe_id = name
	prompt = "E — сейф"
	_build()
	if Story.has_flag("safe_" + safe_id):
		_opened = true
	_refresh()

func _build() -> void:
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-14, -34), Vector2(14, -34), Vector2(14, 0), Vector2(-14, 0),
	])
	body.color = Color(0.105, 0.110, 0.125)
	add_child(body)

	var rim := Polygon2D.new()
	rim.polygon = PackedVector2Array([
		Vector2(-14, -34), Vector2(14, -34), Vector2(14, -32), Vector2(-14, -32),
	])
	rim.color = Color(0.27, 0.28, 0.31)
	add_child(rim)

	_door = Polygon2D.new()
	_door.polygon = PackedVector2Array([
		Vector2(-12, -32), Vector2(12, -32), Vector2(12, -2), Vector2(-12, -2),
	])
	_door.color = Color(0.150, 0.155, 0.170)
	add_child(_door)

	var dial := Polygon2D.new()
	dial.polygon = PackedVector2Array([
		Vector2(-3.5, -23), Vector2(3.5, -23), Vector2(3.5, -15), Vector2(-3.5, -15),
	])
	dial.color = Color(0.32, 0.33, 0.36)
	add_child(dial)

	var handle := Polygon2D.new()
	handle.polygon = PackedVector2Array([
		Vector2(7, -20), Vector2(10, -20), Vector2(10, -12), Vector2(7, -12),
	])
	handle.color = Color(0.28, 0.29, 0.32)
	add_child(handle)

func _refresh() -> void:
	if _door:
		_door.visible = not _opened
	prompt = "E — сейф" if not _opened else ""

func interact(_player: Node) -> void:
	if _opened:
		return
	UI.show_safe(self)

func try_code(candidate: String) -> bool:
	if candidate != code:
		return false
	_opened = true
	_refresh()
	Inventory.add(loot_item_id, loot_count)
	Story.set_flag("safe_" + safe_id)
	return true

func is_opened() -> bool:
	return _opened

## Открытый сейф больше не реагирует на E — иначе игрок видит пустую подсказку.
func can_interact() -> bool:
	if _opened:
		return false
	return super.can_interact()

func get_code() -> String:
	return code