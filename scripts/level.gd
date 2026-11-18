extends Node2D

## Уровень: тайлсет нужен только для коллизии, визуал рисует scripts/visual.gd
## plan_id: 0 — двор, 1 — комната-интерьер

const TILE := 16
const TEX := preload("res://assets/tileset.png")
const VISUAL := preload("res://scripts/visual.gd")
const DETAIL := preload("res://scripts/detail.gd")

const T_EMPTY := 0
const T_STONE := 1
const T_MOSS := 2
const T_BRICK := 3
const T_WOOD := 4
const T_METAL := 5
const T_DEEP := 6
const T_LIGHT := 7

const SOLID := [T_STONE, T_MOSS, T_BRICK, T_WOOD, T_METAL, T_LIGHT]

@export var map_w := 110
@export var map_h := 20
@export var plan_id := 0

var _tileset: TileSet
var _layer: TileMapLayer
var _cells: Dictionary = {}

func _ready() -> void:
	_tileset = _make_tileset()

	_layer = TileMapLayer.new()
	_layer.name = "Collision"
	_layer.tile_set = _tileset
	_layer.visible = false
	add_child(_layer)

	match plan_id:
		1:
			_plan_room()
		2:
			_plan_basement()
		3:
			_plan_attic()
		4:
			_plan_roof()
		_:
			_plan_courtyard()

	_paint()

	var v = VISUAL.new()
	v.name = "Visual"
	add_child(v)
	v.call("setup", _cells)

	var d = DETAIL.new()
	d.name = "Detail"
	add_child(d)
	d.call("setup", _cells, 20261117)

# ─────────────────────────────────────────────────────────────
#  Коллизия
# ─────────────────────────────────────────────────────────────

func _make_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)

	var atlas := TileSetAtlasSource.new()
	atlas.texture = TEX
	atlas.texture_region_size = Vector2i(TILE, TILE)
	for i in 16:
		atlas.create_tile(Vector2i(i % 8, i >> 3))
	ts.add_source(atlas, 0)

	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)

	# ВАЖНО: точки полигона задаются от ЦЕНТРА тайла, а не от угла.
	var full := PackedVector2Array([
		Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8),
	])
	for id in SOLID:
		for v in [0, 8]:
			var tid: int = id + v
			var td := atlas.get_tile_data(Vector2i(tid % 8, tid >> 3), 0)
			if td == null:
				continue
			td.set_collision_polygons_count(0, 1)
			td.set_collision_polygon_points(0, 0, full)

	return ts

func _paint() -> void:
	for pos: Vector2i in _cells:
		var id: int = _cells[pos]
		var h: int = absi(pos.x * 73856093 ^ pos.y * 19349663)
		var tid: int = id + (8 if (h % 100) < 45 else 0)
		_layer.set_cell(pos, 0, Vector2i(tid % 8, tid >> 3))

# ─────────────────────────────────────────────────────────────
#  Правки карты
# ─────────────────────────────────────────────────────────────

func _put(x: int, y: int, t: int) -> void:
	if x < 0 or y < 0 or x >= map_w or y >= map_h:
		return
	if t == T_EMPTY:
		_cells.erase(Vector2i(x, y))
	else:
		_cells[Vector2i(x, y)] = t

func _rect(x: int, y: int, w: int, h: int, t: int) -> void:
	for j in h:
		for i in w:
			_put(x + i, y + j, t)

func _hole(x: int, y: int, w: int, h: int) -> void:
	_rect(x, y, w, h, T_EMPTY)

# ─────────────────────────────────────────────────────────────
#  Двор
# ─────────────────────────────────────────────────────────────

func _plan_courtyard() -> void:
	var gy := 16

	_rect(0, gy, map_w, map_h - gy, T_STONE)
	_rect(0, gy, map_w, 1, T_MOSS)

	_rect(2, 9, 26, gy - 9, T_DEEP)
	_rect(32, 7, 20, gy - 7, T_DEEP)
	_rect(56, 10, 16, gy - 10, T_DEEP)

	_rect(0, 4, 1, gy - 4, T_BRICK)
	_rect(1, 5, 1, gy - 5, T_BRICK)
	_rect(2, 6, 1, gy - 6, T_BRICK)

	_rect(74, 3, 34, gy - 3, T_BRICK)
	_rect(74, 3, 34, 1, T_LIGHT)
	_hole(74, 3, 2, 1)
	_hole(82, 3, 1, 2)
	_hole(95, 3, 3, 1)

	# дверной проём в доме — вход в интерьер
	_hole(74, 13, 1, 3)

	_rect(map_w - 1, 0, 1, gy, T_BRICK)

# ─────────────────────────────────────────────────────────────
#  Комната (интерьер)
# ─────────────────────────────────────────────────────────────

func _plan_room() -> void:
	var gy := map_h - 3   # линия пола

	# пол и потолок
	_rect(0, gy, map_w, map_h - gy, T_STONE)
	_rect(0, gy, map_w, 1, T_WOOD)
	_rect(0, 0, map_w, 2, T_BRICK)

	# стены
	_rect(0, 2, 1, gy - 2, T_BRICK)
	_rect(map_w - 1, 2, 1, gy - 2, T_BRICK)

	# плинтус
	_rect(1, gy - 1, map_w - 2, 1, T_WOOD)
# ─────────────────────────────────────────────────────────────
#  Подвал
# ─────────────────────────────────────────────────────────────

func _plan_basement() -> void:
	var gy := map_h - 2   # линия пола

	_rect(0, gy, map_w, 2, T_STONE)          # пол
	_rect(0, 0, map_w, 2, T_BRICK)           # потолок
	_rect(0, 0, 1, gy, T_BRICK)              # левая стена
	_rect(map_w - 1, 0, 1, gy, T_BRICK)      # правая стена

	# колонны — ФОН, без коллизии (иначе перекрывают проход)
	_rect(9, 4, 1, gy - 4, T_DEEP)
	_rect(20, 4, 1, gy - 4, T_DEEP)

	# мусор — только фон, через него можно идти
	_rect(12, gy - 2, 3, 2, T_DEEP)
	_rect(23, gy - 2, 2, 2, T_DEEP)
	_rect(26, gy - 2, 2, 2, T_DEEP)

# ─────────────────────────────────────────────────────────────
#  Чердак
# ─────────────────────────────────────────────────────────────

func _plan_attic() -> void:
	var gy := map_h - 2

	_rect(0, gy, map_w, 2, T_WOOD)           # пол
	_rect(0, 0, map_w, 2, T_BRICK)           # скат крыши
	_rect(0, 0, 1, gy, T_BRICK)
	_rect(map_w - 1, 0, 1, gy, T_BRICK)

	# стропила — ФОН, без коллизии
	_rect(7, 2, 1, gy - 2, T_DEEP)
	_rect(19, 2, 1, gy - 2, T_DEEP)

	# хлам — только фон
	_rect(11, gy - 2, 3, 2, T_DEEP)
	_rect(23, gy - 2, 4, 2, T_DEEP)

# ─────────────────────────────────────────────────────────────
#  Крыша
# ─────────────────────────────────────────────────────────────

func _plan_roof() -> void:
	var gy := map_h - 2   # линия пола
	# только пол для коллизии — парапет и декор рисуются вручную в сцене
	_rect(0, gy, map_w, 2, T_STONE)
