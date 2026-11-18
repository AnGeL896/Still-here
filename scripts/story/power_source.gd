extends Interactable
class_name PowerSource

## Щиток с предохранителями. Работает как источник питания,
## когда все слоты заполнены.

signal power_changed(powered: bool)

@export var required_fuses := 3
@export var fuse_item_id := "fuse"
@export var slot_color := Color(0.16, 0.15, 0.13)
@export var filled_color := Color(0.42, 0.95, 0.62)

var _slots := 0
var _powered := false
var _indicators: Array[Polygon2D] = []

func _ready() -> void:
	super._ready()
	add_to_group("power_source")
	prompt = "E — вставить предохранитель"

	# слоты переживают выход из комнаты
	var saved := int(Story.get_value("fusebox_" + name, 0))
	_slots = clampi(saved, 0, required_fuses)
	_powered = _slots >= required_fuses

	_build()
	_refresh()

	if _powered:
		power_changed.emit(true)

func _build() -> void:
	# корпус щитка — светлее стены, чтобы не сливался
	var w := 26.0
	var h := 30.0
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-w * 0.5, -h), Vector2(w * 0.5, -h),
		Vector2(w * 0.5, 0.0), Vector2(-w * 0.5, 0.0),
	])
	body.color = Color(0.175, 0.180, 0.195)
	body.position = Vector2(0, -h)
	add_child(body)

	# светлая кромка
	var edge := Polygon2D.new()
	edge.polygon = PackedVector2Array([
		Vector2(-w * 0.5, -h), Vector2(w * 0.5, -h),
		Vector2(w * 0.5, -h + 1.5), Vector2(-w * 0.5, -h + 1.5),
	])
	edge.color = Color(0.36, 0.37, 0.40)
	edge.position = Vector2(0, -h)
	add_child(edge)

	# предупреждающая полоса
	var stripe := Polygon2D.new()
	stripe.polygon = PackedVector2Array([
		Vector2(-w * 0.5 + 2, -6), Vector2(w * 0.5 - 2, -6),
		Vector2(w * 0.5 - 2, -3), Vector2(-w * 0.5 + 2, -3),
	])
	stripe.color = Color(0.52, 0.42, 0.16)
	add_child(stripe)

	# индикаторы слотов
	var step := 7.0
	var start_x := -((required_fuses - 1) * step) * 0.5
	for i in required_fuses:
		var ind := Polygon2D.new()
		ind.polygon = PackedVector2Array([
			Vector2(-2.5, -4), Vector2(2.5, -4),
			Vector2(2.5, 4), Vector2(-2.5, 4),
		])
		ind.color = slot_color
		ind.position = Vector2(start_x + i * step, -h * 0.55)
		add_child(ind)
		_indicators.append(ind)

func _refresh() -> void:
	for i in _indicators.size():
		_indicators[i].color = filled_color if i < _slots else slot_color

	prompt = "E — вставить предохранитель (%d/%d)" % [_slots, required_fuses]

func interact(_player: Node) -> void:
	if _powered:
		return
	if Inventory.take(fuse_item_id):
		_slots += 1
		Story.set_value("fusebox_" + name, _slots)
		_refresh()
		if _slots >= required_fuses:
			_powered = true
			power_changed.emit(true)

func is_powered() -> bool:
	return _powered

func get_slots() -> int:
	return _slots