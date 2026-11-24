extends Node2D

## Визуальный слой комнаты 4.
## pass_index 0 — подложка: обои, пол, потолок, плинтус, ambient occlusion.
## pass_index 1 — поверх: детали мебели, контуры, свет, пыль.
##
## Скрипт локальный для одной сцены: не меняет тайлсет, коллизию и интерактивные объекты.

@export var pass_index := 0

const W := 480.0
const H := 272.0
const WALL_L := 16.0
const WALL_R := 464.0
const CEIL_Y := 32.0
const BASE_Y := 208.0
const FLOOR_Y := 224.0

const C_WALL := Color(0.140, 0.176, 0.172)
const C_WALL_HI := Color(0.175, 0.212, 0.204)
const C_WALL_LO := Color(0.090, 0.120, 0.126)
const C_LINE := Color(0.035, 0.033, 0.032)
const C_WOOD := Color(0.235, 0.190, 0.150)
const C_WOOD_D := Color(0.150, 0.120, 0.094)
const C_HL := Color(0.430, 0.365, 0.280)
const C_METAL := Color(0.380, 0.390, 0.410)
const C_DARK := Color(0.0, 0.0, 0.0)

var _rng := RandomNumberGenerator.new()
var _t := 0.0

func _ready() -> void:
	_rng.seed = 77123
	set_process(pass_index == 1)

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

# ─── примитивы ────────────────────────────────────────────────

func _r(x: float, y: float, w: float, h: float, c: Color) -> void:
	draw_rect(Rect2(x, y, w, h), c)

func _poly(pts: PackedVector2Array, c: Color) -> void:
	draw_colored_polygon(pts, c)

func _ln(x1: float, y1: float, x2: float, y2: float, c: Color, w := 1.0) -> void:
	draw_line(Vector2(x1, y1), Vector2(x2, y2), c, w)

func _ol(x: float, y: float, w: float, h: float, c: Color) -> void:
	draw_rect(Rect2(x, y, w, h), c, false, 1.0)

func _vg(x: float, y: float, w: float, h: float, top: Color, bottom: Color, steps: int) -> void:
	var n := maxi(steps, 1)
	for i in n:
		var k := float(i) / float(maxi(n - 1, 1))
		_r(x, y + h * float(i) / float(n), w, h / float(n) + 0.6, top.lerp(bottom, k))

func _hgrad(x: float, y: float, w: float, h: float, left: Color, right: Color, steps: int) -> void:
	var n := maxi(steps, 1)
	for i in n:
		var k := float(i) / float(maxi(n - 1, 1))
		_r(x + w * float(i) / float(n), y, w / float(n) + 0.6, h, left.lerp(right, k))

# ─── слой 0: подложка ─────────────────────────────────────────

func _draw() -> void:
	if pass_index == 0:
		_draw_base()
	else:
		_draw_overlay()

func _draw_base() -> void:
	_wall()
	_floor()
	_ceiling()
	_baseboard()
	_occlusion()

func _wall() -> void:
	# грунт: тёмный низ, светлее к центру, снова темнее к потолку
	_r(WALL_L, CEIL_Y, WALL_R - WALL_L, BASE_Y - CEIL_Y, C_WALL)
	_vg(WALL_L, CEIL_Y, WALL_R - WALL_L, 44.0, C_WALL_LO, C_WALL, 6)
	_vg(WALL_L, BASE_Y - 46.0, WALL_R - WALL_L, 46.0, C_WALL, C_WALL_LO, 6)

	# полосы обоев
	var x := 19.0
	var i := 0
	while x < WALL_R - 2.0:
		var c := Color(1, 1, 1, 0.045) if i % 2 == 0 else Color(0, 0, 0, 0.065)
		_r(x, CEIL_Y, 1.0, BASE_Y - CEIL_Y, c)
		x += 11.0
		i += 1

	# швы обоев
	x = 41.0
	while x < WALL_R - 2.0:
		_r(x, CEIL_Y, 1.0, BASE_Y - CEIL_Y, Color(0, 0, 0, 0.13))
		x += 44.0

	# пятна и потёки
	_poly(PackedVector2Array([
		Vector2(92, 34), Vector2(122, 33), Vector2(130, 46),
		Vector2(120, 58), Vector2(100, 56), Vector2(88, 46),
	]), Color(0.10, 0.095, 0.085, 0.16))
	_poly(PackedVector2Array([
		Vector2(248, 118), Vector2(290, 118), Vector2(286, 136),
		Vector2(266, 141), Vector2(250, 132),
	]), Color(0.09, 0.09, 0.085, 0.13))
	_poly(PackedVector2Array([
		Vector2(430, 34), Vector2(462, 33), Vector2(463, 58),
		Vector2(446, 66), Vector2(432, 52),
	]), Color(0.08, 0.08, 0.075, 0.18))

	# трещины
	_crack(PackedVector2Array([
		Vector2(58, 33), Vector2(63, 48), Vector2(58, 62), Vector2(62, 74),
	]))
	_crack(PackedVector2Array([
		Vector2(402, 33), Vector2(397, 47), Vector2(403, 58), Vector2(399, 66),
	]))
	_crack(PackedVector2Array([
		Vector2(463, 118), Vector2(447, 124), Vector2(436, 121), Vector2(428, 126),
	]))

	# обои отошли
	_poly(PackedVector2Array([
		Vector2(198, 148), Vector2(212, 145), Vector2(215, 160),
		Vector2(206, 168), Vector2(196, 162),
	]), Color(0.215, 0.208, 0.192, 0.55))
	_ln(198, 148, 206, 168, Color(0, 0, 0, 0.22))
	_ln(206, 168, 215, 160, Color(0, 0, 0, 0.18))
	_poly(PackedVector2Array([
		Vector2(326, 58), Vector2(340, 60), Vector2(338, 72),
		Vector2(328, 74), Vector2(323, 66),
	]), Color(0.205, 0.198, 0.182, 0.45))

	# карниз
	_r(WALL_L, 44.0, WALL_R - WALL_L, 1.0, Color(0, 0, 0, 0.28))
	_r(WALL_L, 45.0, WALL_R - WALL_L, 1.0, Color(1, 1, 1, 0.05))

	# панель ниже
	_r(WALL_L, 176.0, WALL_R - WALL_L, 1.0, Color(0, 0, 0, 0.22))
	_r(WALL_L, 177.0, WALL_R - WALL_L, 1.0, Color(1, 1, 1, 0.04))
	_r(WALL_L, 178.0, WALL_R - WALL_L, BASE_Y - 178.0, Color(0, 0, 0, 0.07))

	# выцветшее место от снятой рамки
	_r(300.0, 96.0, 18.0, 16.0, Color(0.85, 0.82, 0.72, 0.05))
	_r(308.0, 93.0, 1.0, 1.0, Color(0.05, 0.05, 0.05, 0.55))

	# плитка над мойкой
	for gx in range(96, 129, 8):
		_r(float(gx), 164.0, 1.0, 26.0, Color(0, 0, 0, 0.10))
	for gy in range(164, 191, 8):
		_r(96.0, float(gy), 32.0, 1.0, Color(0, 0, 0, 0.10))

	# шум: снимает плоскость
	for n in 240:
		var px := _rng.randf_range(WALL_L + 1.0, WALL_R - 2.0)
		var py := _rng.randf_range(CEIL_Y + 1.0, BASE_Y - 2.0)
		var light := _rng.randf() < 0.5
		_r(px, py, 1.0, 1.0, Color(1, 1, 1, 0.022) if light else Color(0, 0, 0, 0.05))

func _crack(pts: PackedVector2Array) -> void:
	draw_polyline(pts, Color(0.02, 0.02, 0.022, 0.55), 1.0)
	var shifted := PackedVector2Array()
	for p in pts:
		shifted.append(p + Vector2(1.0, 0.0))
	draw_polyline(shifted, Color(1, 1, 1, 0.05), 1.0)

func _floor() -> void:
	# доски: тёплые и холодные полосы, стыки, гвозди
	var y := FLOOR_Y
	var i := 0
	while y < H:
		var h := 7.0 if i % 2 == 0 else 6.0
		var warm := 0.020 + 0.018 * float((i * 37) % 5) / 4.0
		_r(0.0, y, W, h, Color(0.95, 0.78, 0.55, warm))
		_r(0.0, y, W, 1.0, Color(0, 0, 0, 0.26))
		# стык со смещением
		var jx := 26.0 + float((i * 67) % 360)
		_r(jx, y + 1.0, 1.0, h - 1.0, Color(0, 0, 0, 0.20))
		_r(jx + 1.0, y + 1.0, 1.0, 1.0, Color(0, 0, 0, 0.35))
		y += h
		i += 1

	# затёртости
	for n in 9:
		var sx := _rng.randf_range(4.0, W - 30.0)
		var sy := _rng.randf_range(FLOOR_Y + 2.0, H - 2.0)
		_ln(sx, sy, sx + _rng.randf_range(6.0, 22.0), sy, Color(0.85, 0.78, 0.62, 0.055))

func _ceiling() -> void:
	# лёгкая фактура плиты
	for n in 90:
		var px := _rng.randf_range(0.0, W)
		var py := _rng.randf_range(0.0, CEIL_Y - 1.0)
		_r(px, py, 1.0, 1.0, Color(0, 0, 0, 0.05))
	_poly(PackedVector2Array([
		Vector2(180, 2), Vector2(214, 1), Vector2(222, 10),
		Vector2(206, 16), Vector2(186, 12),
	]), Color(0.06, 0.06, 0.058, 0.35))
	_crack(PackedVector2Array([
		Vector2(250, 1), Vector2(256, 12), Vector2(252, 22),
	]))

func _baseboard() -> void:
	_r(0.0, BASE_Y, W, 1.0, Color(1, 1, 1, 0.07))
	_r(0.0, BASE_Y + 15.0, W, 1.0, Color(0, 0, 0, 0.30))
	var x := 12.0
	while x < W:
		_r(x, BASE_Y + 1.0, 1.0, 14.0, Color(0, 0, 0, 0.16))
		x += 32.0

func _occlusion() -> void:
	# углы
	_hgrad(WALL_L, CEIL_Y, 10.0, BASE_Y - CEIL_Y, Color(0, 0, 0, 0.30), Color(0, 0, 0, 0.0), 5)
	_hgrad(WALL_R - 10.0, CEIL_Y, 10.0, BASE_Y - CEIL_Y, Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.30), 5)
	# стык с потолком
	_vg(WALL_L, CEIL_Y, WALL_R - WALL_L, 9.0, Color(0, 0, 0, 0.35), Color(0, 0, 0, 0.0), 4)
	# стык с полом
	_vg(WALL_L, BASE_Y - 10.0, WALL_R - WALL_L, 10.0, Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.30), 4)
	_vg(0.0, FLOOR_Y, W, 7.0, Color(0, 0, 0, 0.30), Color(0, 0, 0, 0.0), 3)

	# тени под мебелью (рисуются под объектами)
	_r(124.0, 205.0, 32.0, 4.0, Color(0, 0, 0, 0.30))
	_r(196.0, 205.0, 28.0, 4.0, Color(0, 0, 0, 0.24))
	_r(284.0, 205.0, 52.0, 5.0, Color(0, 0, 0, 0.30))
	_r(94.0, 204.0, 36.0, 5.0, Color(0, 0, 0, 0.30))
	_r(366.0, 204.0, 52.0, 6.0, Color(0, 0, 0, 0.32))
	_r(334.0, 205.0, 40.0, 5.0, Color(0, 0, 0, 0.26))
	_r(336.0, 205.0, 34.0, 5.0, Color(0, 0, 0, 0.22))
	_r(412.0, 206.0, 34.0, 4.0, Color(0, 0, 0, 0.26))
	_r(238.0, 205.0, 24.0, 5.0, Color(0, 0, 0, 0.20))

	# тень от щитка и двери на стене
	_r(93.0, 178.0, 3.0, 30.0, Color(0, 0, 0, 0.18))
	_r(39.0, 176.0, 4.0, 32.0, Color(0, 0, 0, 0.16))
	# заглубление окна
	_r(240.0, 63.0, 54.0, 4.0, Color(0, 0, 0, 0.22))
	_r(240.0, 67.0, 3.0, 52.0, Color(0, 0, 0, 0.18))

# ─── слой 1: поверх ───────────────────────────────────────────

func _draw_overlay() -> void:
	_window()
	_shaft()
	_lamp()
	_table()
	_cupboard()
	_drawer()
	_counter()
	_bed()
	_shelf()
	_pictures()
	_boxes()
	_safe()
	_fusebox()
	_door()
	_hatch()
	_rug()
	_broom()
	_cobwebs()
	_dust()

func _window() -> void:
	# подоконник
	_r(239.0, 119.0, 56.0, 2.0, Color(0.205, 0.195, 0.175))
	_r(239.0, 119.0, 56.0, 1.0, Color(0.360, 0.340, 0.300, 0.55))
	_r(239.0, 121.0, 56.0, 2.0, Color(0, 0, 0, 0.30))
	# кромка рамы
	_r(243.0, 67.0, 48.0, 1.0, Color(0.55, 0.58, 0.62, 0.18))
	_r(243.0, 67.0, 1.0, 52.0, Color(0.55, 0.58, 0.62, 0.14))
	# блик на стекле
	_ln(252.0, 76.0, 268.0, 110.0, Color(0.78, 0.85, 0.98, 0.07))
	# трещина в стекле
	draw_polyline(PackedVector2Array([
		Vector2(262, 78), Vector2(268, 90), Vector2(264, 100), Vector2(270, 108),
	]), Color(0.85, 0.90, 1.0, 0.22), 1.0)
	# штора слева
	_r(232.0, 66.0, 20.0, 1.0, Color(0.26, 0.23, 0.19))
	_poly(PackedVector2Array([
		Vector2(235, 68), Vector2(239, 68), Vector2(238, 116),
		Vector2(234, 114),
	]), Color(0.115, 0.110, 0.108, 0.90))
	_poly(PackedVector2Array([
		Vector2(240, 68), Vector2(244, 68), Vector2(243, 118),
		Vector2(239, 115),
	]), Color(0.140, 0.133, 0.128, 0.90))
	_ln(240.5, 69, 240.0, 114, Color(0.55, 0.52, 0.47, 0.10))

func _shaft() -> void:
	_poly(PackedVector2Array([
		Vector2(248, 112), Vector2(286, 112), Vector2(346, 224), Vector2(286, 224),
	]), Color(0.62, 0.72, 0.92, 0.045))
	_poly(PackedVector2Array([
		Vector2(256, 112), Vector2(278, 112), Vector2(324, 224), Vector2(292, 224),
	]), Color(0.78, 0.85, 1.0, 0.032))

func _lamp() -> void:
	var lx := 150.0
	_r(lx - 4.0, 31.0, 8.0, 2.0, Color(0.20, 0.19, 0.17))
	_r(lx - 0.5, 33.0, 1.0, 29.0, Color(0.055, 0.055, 0.065))
	_poly(PackedVector2Array([
		Vector2(lx - 9.0, 62.0), Vector2(lx + 9.0, 62.0),
		Vector2(lx + 6.0, 69.0), Vector2(lx - 6.0, 69.0),
	]), Color(0.150, 0.145, 0.135))
	_r(lx - 7.0, 68.0, 14.0, 1.0, Color(0.62, 0.50, 0.30, 0.45))
	_r(lx - 2.0, 69.0, 4.0, 3.0, Color(1.0, 0.88, 0.62))
	draw_circle(Vector2(lx, 70.5), 7.0, Color(1.0, 0.86, 0.56, 0.05))
	draw_circle(Vector2(lx, 70.5), 13.0, Color(1.0, 0.84, 0.52, 0.025))

func _table() -> void:
	_ol(288.0, 192.0, 44.0, 4.0, Color(0, 0, 0, 0.45))
	_r(289.0, 192.0, 42.0, 1.0, Color(0.52, 0.44, 0.33, 0.55))
	_r(290.0, 194.0, 40.0, 1.0, Color(0.35, 0.28, 0.21, 0.35))
	_r(288.0, 196.0, 44.0, 1.0, Color(0, 0, 0, 0.35))
	_ol(292.0, 196.0, 4.0, 12.0, Color(0, 0, 0, 0.35))
	_r(292.0, 196.0, 1.0, 12.0, Color(0.30, 0.25, 0.20, 0.40))
	_ol(324.0, 196.0, 4.0, 12.0, Color(0, 0, 0, 0.35))
	# кружка
	_r(318.0, 187.0, 5.0, 5.0, Color(0.60, 0.60, 0.58))
	_r(318.0, 187.0, 5.0, 1.0, Color(0.78, 0.78, 0.74))
	_r(323.0, 188.0, 1.0, 2.0, Color(0.55, 0.55, 0.53))
	_r(317.0, 192.0, 7.0, 1.0, Color(0, 0, 0, 0.25))

func _cupboard() -> void:
	_r(129.0, 174.0, 22.0, 1.0, Color(0.36, 0.30, 0.24, 0.45))
	_r(151.0, 175.0, 1.0, 33.0, Color(0, 0, 0, 0.28))
	_r(132.0, 173.0, 9.0, 1.0, Color(0.55, 0.52, 0.45, 0.10))

func _drawer() -> void:
	_r(201.0, 194.0, 18.0, 1.0, Color(0.36, 0.30, 0.24, 0.40))
	_r(219.0, 195.0, 1.0, 13.0, Color(0, 0, 0, 0.25))

func _counter() -> void:
	_r(99.0, 190.0, 26.0, 1.0, Color(0.44, 0.46, 0.50, 0.45))
	_r(111.0, 195.0, 1.0, 13.0, Color(0, 0, 0, 0.30))
	_r(106.0, 199.0, 4.0, 1.0, Color(0.55, 0.56, 0.58, 0.55))
	# смеситель
	_r(104.0, 185.0, 1.0, 5.0, Color(0.62, 0.65, 0.68, 0.70))
	_r(104.0, 185.0, 4.0, 1.0, Color(0.62, 0.65, 0.68, 0.70))
	_r(107.0, 186.0, 1.0, 1.0, Color(0.72, 0.75, 0.78, 0.60))

func _bed() -> void:
	_r(370.0, 188.0, 3.0, 20.0, Color(0.105, 0.088, 0.070))
	_r(411.0, 188.0, 3.0, 20.0, Color(0.105, 0.088, 0.070))
	_r(370.0, 188.0, 1.0, 20.0, Color(0.32, 0.27, 0.21, 0.45))
	_r(373.0, 188.0, 38.0, 1.0, Color(0.55, 0.54, 0.52, 0.35))
	_ln(388.0, 189.0, 388.0, 194.0, Color(0.45, 0.44, 0.42, 0.25))
	_ln(396.0, 189.0, 396.0, 194.0, Color(0.45, 0.44, 0.42, 0.22))
	_r(375.0, 187.0, 10.0, 1.0, Color(0.66, 0.65, 0.61, 0.35))
	_r(374.0, 192.0, 12.0, 1.0, Color(0, 0, 0, 0.22))
	_r(370.0, 207.0, 44.0, 1.0, Color(0, 0, 0, 0.35))

func _shelf() -> void:
	_r(163.0, 132.0, 30.0, 1.0, Color(0.36, 0.30, 0.23, 0.40))
	_r(166.0, 126.0, 4.0, 6.0, Color(0.30, 0.32, 0.30))
	_r(166.0, 126.0, 4.0, 1.0, Color(0.52, 0.55, 0.52, 0.40))
	_r(172.0, 125.0, 3.0, 7.0, Color(0.34, 0.30, 0.24))
	_r(172.0, 125.0, 3.0, 1.0, Color(0.55, 0.50, 0.40, 0.40))
	_r(180.0, 127.0, 5.0, 5.0, Color(0.28, 0.30, 0.34))
	_r(180.0, 127.0, 5.0, 1.0, Color(0.48, 0.50, 0.55, 0.35))

func _pictures() -> void:
	_ol(196.0, 84.0, 16.0, 16.0, Color(0.55, 0.52, 0.45, 0.16))
	_r(198.0, 92.0, 12.0, 1.0, Color(0.40, 0.43, 0.45, 0.30))
	_r(198.0, 93.0, 12.0, 5.0, Color(0.08, 0.09, 0.10, 0.30))
	_r(203.0, 82.0, 1.0, 1.0, Color(0.55, 0.55, 0.55, 0.45))

	_ol(352.0, 96.0, 14.0, 14.0, Color(0.55, 0.52, 0.45, 0.14))
	_r(354.0, 103.0, 10.0, 1.0, Color(0.40, 0.43, 0.45, 0.25))
	_r(354.0, 104.0, 10.0, 4.0, Color(0.08, 0.09, 0.10, 0.28))
	_r(358.0, 94.0, 1.0, 1.0, Color(0.55, 0.55, 0.55, 0.40))

func _boxes() -> void:
	_r(346.0, 192.0, 1.0, 16.0, Color(0.62, 0.56, 0.42, 0.22))
	_r(340.0, 196.0, 5.0, 3.0, Color(0.68, 0.64, 0.54, 0.30))
	_r(363.0, 198.0, 1.0, 10.0, Color(0.62, 0.56, 0.42, 0.18))

func _safe() -> void:
	_r(339.0, 174.0, 26.0, 1.0, Color(0.42, 0.44, 0.48, 0.40))
	_r(365.0, 175.0, 1.0, 33.0, Color(0, 0, 0, 0.25))
	_r(342.0, 208.0, 1.0, 3.0, Color(0.35, 0.22, 0.15, 0.22))

func _fusebox() -> void:
	_r(79.0, 32.0, 2.0, 146.0, Color(0.10, 0.105, 0.115))
	_r(79.0, 32.0, 1.0, 146.0, Color(0.26, 0.27, 0.29, 0.35))
	_r(76.0, 60.0, 8.0, 1.0, Color(0.18, 0.185, 0.195))
	_r(76.0, 100.0, 8.0, 1.0, Color(0.18, 0.185, 0.195))
	_r(76.0, 140.0, 8.0, 1.0, Color(0.18, 0.185, 0.195))
	_r(68.0, 178.0, 24.0, 1.0, Color(0.46, 0.47, 0.49, 0.40))

func _door() -> void:
	_r(21.0, 176.0, 1.0, 32.0, Color(0.30, 0.25, 0.20, 0.35))
	_ol(24.0, 182.0, 12.0, 10.0, Color(0, 0, 0, 0.30))
	_ol(24.0, 196.0, 12.0, 10.0, Color(0, 0, 0, 0.30))
	_r(25.0, 183.0, 10.0, 1.0, Color(0.55, 0.48, 0.38, 0.18))
	_r(25.0, 197.0, 10.0, 1.0, Color(0.55, 0.48, 0.38, 0.15))
	_r(34.0, 193.0, 2.0, 1.0, Color(0.58, 0.54, 0.45, 0.60))
	_r(22.0, 207.0, 16.0, 1.0, Color(1.0, 0.85, 0.55, 0.20))

func _hatch() -> void:
	_r(416.0, 202.0, 28.0, 1.0, Color(0.35, 0.30, 0.24, 0.35))
	_ln(417.0, 205.0, 443.0, 205.0, Color(0, 0, 0, 0.18))
	_r(428.0, 204.0, 3.0, 1.0, Color(0.50, 0.48, 0.42, 0.50))

func _rug() -> void:
	_ol(198.0, 205.0, 106.0, 3.0, Color(0.48, 0.34, 0.31, 0.30))
	_r(240.0, 206.0, 10.0, 2.0, Color(0.60, 0.52, 0.44, 0.10))
	_r(266.0, 206.0, 6.0, 1.0, Color(0.60, 0.52, 0.44, 0.10))

func _broom() -> void:
	_ln(458.0, 208.0, 450.0, 172.0, Color(0.36, 0.29, 0.21, 0.85), 1.0)
	_poly(PackedVector2Array([
		Vector2(445, 168), Vector2(454, 170), Vector2(452, 178), Vector2(443, 176),
	]), Color(0.30, 0.26, 0.16, 0.90))
	_ln(446.0, 172.0, 452.0, 173.0, Color(0.55, 0.48, 0.30, 0.30))

func _cobwebs() -> void:
	_ln(17.0, 33.0, 33.0, 33.0, Color(0.75, 0.78, 0.80, 0.05))
	_ln(17.0, 33.0, 17.0, 49.0, Color(0.75, 0.78, 0.80, 0.05))
	_ln(17.0, 33.0, 27.0, 43.0, Color(0.75, 0.78, 0.80, 0.04))
	_ln(463.0, 33.0, 447.0, 33.0, Color(0.75, 0.78, 0.80, 0.04))
	_ln(463.0, 33.0, 463.0, 47.0, Color(0.75, 0.78, 0.80, 0.04))

func _dust() -> void:
	for i in 26:
		var fi := float(i)
		var px := 250.0 + fmod(fi * 47.0, 86.0)
		var py := 116.0 + fmod(fi * 71.0, 104.0)
		px += sin(_t * 0.23 + fi * 1.7) * 4.0
		py += sin(_t * 0.37 + fi * 0.9) * 3.0
		# только внутри конуса света
		var edge := 250.0 + (py - 116.0) * 0.28
		if px < edge or px > edge + 96.0:
			continue
		var a := 0.10 + 0.10 * (0.5 + 0.5 * sin(_t * 0.8 + fi))
		_r(px, py, 1.0, 1.0, Color(1.0, 0.96, 0.86, a))