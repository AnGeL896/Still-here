extends Node2D

## Рисует уровень слитыми горизонтальными полосами вместо тайлов.
## Тайлсет остаётся только для коллизии — визуально сетки не видно.

const TILE := 16

const COLORS := {
	1: Color(0.169, 0.188, 0.235),   # бурый камень
	2: Color(0.161, 0.200, 0.192),   # камень с мхом
	3: Color(0.184, 0.157, 0.157),   # кирпич
	4: Color(0.227, 0.192, 0.161),   # доски
	5: Color(0.184, 0.208, 0.243),   # металл
	6: Color(0.078, 0.094, 0.125),   # дальний план
	7: Color(0.259, 0.275, 0.302),   # бетон
}

var _fills: Array = []
var _edges: Array = []

func _ready() -> void:
	var sh: Shader = preload("res://assets/visual.gdshader")
	var mat := ShaderMaterial.new()
	mat.shader = sh
	material = mat

func setup(cells: Dictionary) -> void:
	_fills.clear()
	_edges.clear()

	# группируем клетки по строкам
	var rows: Dictionary = {}
	for pos: Vector2i in cells:
		if not rows.has(pos.y):
			rows[pos.y] = {}
		rows[pos.y][pos.x] = cells[pos]

	var ys: Array = rows.keys()
	ys.sort()

	for y: int in ys:
		var row: Dictionary = rows[y]
		var xs: Array = row.keys()
		xs.sort()

		var start: int = xs[0]
		var prev: int = start
		var mat: int = row[start]

		for i in range(1, xs.size()):
			var x: int = xs[i]
			if x == prev + 1 and row[x] == mat:
				prev = x
				continue
			_emit(y, start, prev, mat, rows)
			start = x
			prev = x
			mat = row[x]
		_emit(y, start, prev, mat, rows)

	queue_redraw()

func _emit(y: int, x0: int, x1: int, mat: int, rows: Dictionary) -> void:
	var col: Color = COLORS.get(mat, Color(1.0, 0.0, 1.0))

	_fills.append({
		"rect": Rect2(x0 * TILE, y * TILE, (x1 - x0 + 1) * TILE, TILE),
		"color": col,
	})

	# Вертикальные границы силуэта — чтобы дом читался объёмом, а не вырезкой
	var row: Dictionary = rows.get(y, {})
	if not row.has(x0 - 1):
		_edges.append({
			"rect": Rect2(x0 * TILE, y * TILE, 1.0, TILE),
			"color": col.darkened(0.32),
		})
	if not row.has(x1 + 1):
		_edges.append({
			"rect": Rect2((x1 + 1) * TILE - 1.0, y * TILE, 1.0, TILE),
			"color": col.darkened(0.32),
		})

	# Верхняя грань — только там, где сверху ПУСТО.
	# Если рисовать по «другому материалу», внутри земли появляются фантомные линии.
	var above: Dictionary = rows.get(y - 1, {})
	var seg := -1
	for x in range(x0, x1 + 2):
		var empty_above: bool = x <= x1 and not above.has(x)
		if empty_above and seg < 0:
			seg = x
		elif not empty_above and seg >= 0:
			_edges.append({
				"rect": Rect2(seg * TILE, y * TILE, (x - seg) * TILE, 1.0),
				"color": col.lightened(0.16),
			})
			seg = -1

	# Нижняя тень — симметрично, только под открытым небом
	var below: Dictionary = rows.get(y + 1, {})
	seg = -1
	for x in range(x0, x1 + 2):
		var empty_below: bool = x <= x1 and not below.has(x)
		if empty_below and seg < 0:
			seg = x
		elif not empty_below and seg >= 0:
			_edges.append({
				"rect": Rect2(seg * TILE, (y + 1) * TILE - 1.0, (x - seg) * TILE, 1.0),
				"color": col.darkened(0.38),
			})
			seg = -1

func _draw() -> void:
	for f in _fills:
		draw_rect(f["rect"], f["color"])
	for e in _edges:
		draw_rect(e["rect"], e["color"])