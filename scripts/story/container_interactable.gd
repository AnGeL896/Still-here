extends Interactable
class_name ContainerInteractable

## Шкаф или ящик. Открывается и остаётся открытым.

enum Style { CUPBOARD, DRAWER }

@export var style: Style = Style.CUPBOARD
@export var size := Vector2(22, 28)
@export var closed_prompt := "E — открыть"
@export var open_prompt := "E — закрыть"
@export var start_open := false
## Что выпадает при первом открытии (пусто = ничего)
@export var loot_item_id := ""
@export var loot_count := 1
## Уникальный ключ лута. Пусто = имя узла.
@export var loot_id := ""

const C_FRAME := Color(0.145, 0.118, 0.094)
const C_DOOR := Color(0.215, 0.175, 0.138)
const C_EDGE := Color(0.290, 0.240, 0.190)
const C_INNER := Color(0.026, 0.024, 0.022)
const C_HANDLE := Color(0.075, 0.068, 0.060)
const C_SHADOW := Color(0.0, 0.0, 0.0, 0.35)

var _open := false
var _looted := false
var _closed: Array[Node2D] = []
var _opened: Array[Node2D] = []

func _ready() -> void:
	super._ready()
	if loot_id == "":
		loot_id = name
	_open = start_open
	if loot_id != "" and Story.has_flag("looted_" + loot_id):
		_looted = true
	_build()
	_refresh()

func _poly(pts: PackedVector2Array, col: Color) -> Polygon2D:
	var p := Polygon2D.new()
	p.polygon = pts
	p.color = col
	add_child(p)
	return p

func _rect(x: float, y: float, w: float, h: float, col: Color) -> Polygon2D:
	return _poly(PackedVector2Array([
		Vector2(x, y), Vector2(x + w, y), Vector2(x + w, y + h), Vector2(x, y + h)
	]), col)

func _build() -> void:
	var w := size.x
	var h := size.y

	# тень под объектом
	_poly(PackedVector2Array([
		Vector2(-w * 0.55, -1.0), Vector2(w * 0.55, -1.0),
		Vector2(w * 0.48, 1.5), Vector2(-w * 0.48, 1.5),
	]), C_SHADOW)

	if style == Style.DRAWER:
		_build_drawer(w, h)
	else:
		_build_cupboard(w, h)

func _build_cupboard(w: float, h: float) -> void:
	# корпус (виден всегда)
	_rect(-w * 0.5, -h, w, h, C_FRAME)
	# верхняя кромка
	_rect(-w * 0.5, -h, w, 1.0, C_EDGE)

	# ── закрыто ──
	var dl := _rect(-w * 0.5 + 1.0, -h + 1.5, w * 0.5 - 1.5, h - 2.0, C_DOOR)
	var dr := _rect(0.5, -h + 1.5, w * 0.5 - 1.5, h - 2.0, C_DOOR)
	var seam := _rect(-0.5, -h + 1.5, 1.0, h - 2.0, C_INNER)
	var hl := _rect(-2.5, -h * 0.55, 1.5, 2.5, C_HANDLE)
	var hr := _rect(1.0, -h * 0.55, 1.5, 2.5, C_HANDLE)
	_closed = [dl, dr, seam, hl, hr]

	# ── открыто ──
	var inner := _rect(-w * 0.5 + 2.0, -h + 2.0, w - 4.0, h - 3.0, C_INNER)
	var s1 := _rect(-w * 0.5 + 2.0, -h * 0.62, w - 4.0, 1.0, C_FRAME)
	var s2 := _rect(-w * 0.5 + 2.0, -h * 0.30, w - 4.0, 1.0, C_FRAME)
	# створки, распахнутые к краям
	var odl := _rect(-w * 0.5 - 1.0, -h + 1.5, 2.0, h - 2.0, C_DOOR)
	var odr := _rect(w * 0.5 - 1.0, -h + 1.5, 2.0, h - 2.0, C_DOOR)
	_opened = [inner, s1, s2, odl, odr]

func _build_drawer(w: float, h: float) -> void:
	# корпус
	_rect(-w * 0.5, -h, w, h, C_FRAME)
	_rect(-w * 0.5, -h, w, 1.0, C_EDGE)

	# ── закрыто ──
	var front := _rect(-w * 0.5 + 1.0, -h + 1.5, w - 2.0, h - 2.0, C_DOOR)
	var handle := _rect(-2.5, -h * 0.55, 5.0, 1.5, C_HANDLE)
	_closed = [front, handle]

	# ── открыто ──
	var gap := _rect(-w * 0.5 + 1.0, -h + 1.5, w - 2.0, 4.0, C_INNER)
	var out_front := _rect(-w * 0.5 + 1.0, -h + 5.5, w - 2.0, h - 6.0, C_DOOR)
	var out_handle := _rect(-2.5, -h + 7.0, 5.0, 1.5, C_HANDLE)
	_opened = [gap, out_front, out_handle]

func _refresh() -> void:
	for n in _closed:
		n.visible = not _open
	for n in _opened:
		n.visible = _open
	prompt = open_prompt if _open else closed_prompt

func interact(_player: Node) -> void:
	if not can_interact():
		return
	_open = not _open
	_refresh()

	if _open and loot_item_id != "" and not _looted:
		_looted = true
		Inventory.add(loot_item_id, loot_count)
		if loot_id != "":
			Story.set_flag("looted_" + loot_id)